import { useEffect, useRef, useState, useCallback } from "react";

const BAR_COUNT = 64;
const SEGMENT_COUNT = 10;
const INNER_RADIUS = 110;
const OUTER_RADIUS = 200;
const SEGMENT_GAP = 2;
const BAR_GAP_ANGLE = 0.018;

function easeInOut(t: number) {
  return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}

export default function App() {
  const [isPlaying, setIsPlaying] = useState(false);
  const [levels, setLevels] = useState<number[]>(() => Array(BAR_COUNT).fill(0));
  const animRef = useRef<number | null>(null);
  const timeRef = useRef(0);
  const targetLevels = useRef<number[]>(Array(BAR_COUNT).fill(0));
  const currentLevels = useRef<number[]>(Array(BAR_COUNT).fill(0));

  const generateTargets = useCallback(() => {
    const arr: number[] = [];
    for (let i = 0; i < BAR_COUNT; i++) {
      const angle = (i / BAR_COUNT) * Math.PI * 2;
      // Bass bump at bottom, highs at top
      const baseBias = 0.3 + 0.5 * Math.abs(Math.sin(angle * 0.5));
      arr.push(Math.random() * baseBias + Math.random() * (1 - baseBias) * 0.4);
    }
    return arr;
  }, []);

  useEffect(() => {
    if (!isPlaying) {
      if (animRef.current) cancelAnimationFrame(animRef.current);
      // decay to zero
      let decaying = true;
      const decay = () => {
        currentLevels.current = currentLevels.current.map((v) => {
          const next = v * 0.88;
          return next < 0.005 ? 0 : next;
        });
        setLevels([...currentLevels.current]);
        if (currentLevels.current.some((v) => v > 0)) {
          animRef.current = requestAnimationFrame(decay);
        } else {
          decaying = false;
        }
      };
      animRef.current = requestAnimationFrame(decay);
      return () => {
        if (animRef.current) cancelAnimationFrame(animRef.current);
      };
    }

    targetLevels.current = generateTargets();
    let lastSwap = 0;

    const tick = (ts: number) => {
      if (ts - lastSwap > 120 + Math.random() * 120) {
        targetLevels.current = generateTargets();
        lastSwap = ts;
      }

      currentLevels.current = currentLevels.current.map((v, i) => {
        const target = targetLevels.current[i];
        const speed = target > v ? 0.14 : 0.08;
        return v + (target - v) * speed;
      });

      setLevels([...currentLevels.current]);
      animRef.current = requestAnimationFrame(tick);
    };

    animRef.current = requestAnimationFrame(tick);
    return () => {
      if (animRef.current) cancelAnimationFrame(animRef.current);
    };
  }, [isPlaying, generateTargets]);

  const size = 460;
  const cx = size / 2;
  const cy = size / 2;

  const bars = levels.map((level, i) => {
    const angle = (i / BAR_COUNT) * Math.PI * 2 - Math.PI / 2;
    const halfGap = BAR_GAP_ANGLE / 2;
    const startAngle = angle - (Math.PI / BAR_COUNT) + halfGap;
    const endAngle = angle + (Math.PI / BAR_COUNT) - halfGap;

    const range = OUTER_RADIUS - INNER_RADIUS;
    const activeHeight = range * level;

    const segments: JSX.Element[] = [];
    for (let s = 0; s < SEGMENT_COUNT; s++) {
      const segFraction = s / SEGMENT_COUNT;
      const segEnd = (s + 1) / SEGMENT_COUNT;
      const segInner = INNER_RADIUS + segFraction * range;
      const segOuter = INNER_RADIUS + segEnd * range - SEGMENT_GAP;

      const lit = (s + 1) / SEGMENT_COUNT <= level + 0.05;
      const partiallyLit = !lit && s / SEGMENT_COUNT < level + 0.05;

      if (!lit && !partiallyLit) {
        // dim segment
        const x1i = cx + segInner * Math.cos(startAngle);
        const y1i = cy + segInner * Math.sin(startAngle);
        const x2i = cx + segInner * Math.cos(endAngle);
        const y2i = cy + segInner * Math.sin(endAngle);
        const x1o = cx + segOuter * Math.cos(startAngle);
        const y1o = cy + segOuter * Math.sin(startAngle);
        const x2o = cx + segOuter * Math.cos(endAngle);
        const y2o = cy + segOuter * Math.sin(endAngle);
        segments.push(
          <path
            key={s}
            d={`M ${x1i} ${y1i} A ${segInner} ${segInner} 0 0 1 ${x2i} ${y2i} L ${x2o} ${y2o} A ${segOuter} ${segOuter} 0 0 0 ${x1o} ${y1o} Z`}
            fill="rgba(255,255,255,0.07)"
          />
        );
      } else {
        const x1i = cx + segInner * Math.cos(startAngle);
        const y1i = cy + segInner * Math.sin(startAngle);
        const x2i = cx + segInner * Math.cos(endAngle);
        const y2i = cy + segInner * Math.sin(endAngle);
        const x1o = cx + segOuter * Math.cos(startAngle);
        const y1o = cy + segOuter * Math.sin(startAngle);
        const x2o = cx + segOuter * Math.cos(endAngle);
        const y2o = cy + segOuter * Math.sin(endAngle);

        // color gradient from cyan at base to magenta at top
        const t = s / (SEGMENT_COUNT - 1);
        const r = Math.round(0 + t * 255);
        const g = Math.round(220 - t * 180);
        const b = Math.round(255 - t * 30);
        const opacity = 0.75 + t * 0.25;

        segments.push(
          <path
            key={s}
            d={`M ${x1i} ${y1i} A ${segInner} ${segInner} 0 0 1 ${x2i} ${y2i} L ${x2o} ${y2o} A ${segOuter} ${segOuter} 0 0 0 ${x1o} ${y1o} Z`}
            fill={`rgba(${r},${g},${b},${opacity})`}
          />
        );
      }
    }
    return segments;
  });

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        background: "#0a0a0f",
        fontFamily: "system-ui, sans-serif",
      }}
    >
      {/* Glow backdrop */}
      <div
        style={{
          position: "relative",
          width: size,
          height: size,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        {/* Ambient glow */}
        {isPlaying && (
          <div
            style={{
              position: "absolute",
              width: 260,
              height: 260,
              borderRadius: "50%",
              background: "radial-gradient(circle, rgba(0,200,255,0.12) 0%, rgba(200,0,255,0.06) 60%, transparent 80%)",
              filter: "blur(30px)",
              pointerEvents: "none",
              animation: "pulse 2s ease-in-out infinite",
            }}
          />
        )}

        <svg width={size} height={size} style={{ position: "absolute", top: 0, left: 0 }}>
          <defs>
            <filter id="glow">
              <feGaussianBlur stdDeviation="2.5" result="coloredBlur" />
              <feMerge>
                <feMergeNode in="coloredBlur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
          </defs>
          <g filter="url(#glow)">
            {bars}
          </g>
        </svg>

        {/* Play/Pause button */}
        <button
          onClick={() => setIsPlaying((p) => !p)}
          style={{
            position: "relative",
            zIndex: 10,
            width: 90,
            height: 90,
            borderRadius: "50%",
            border: "2px solid rgba(255,255,255,0.2)",
            background: isPlaying
              ? "rgba(0,200,255,0.15)"
              : "rgba(255,255,255,0.08)",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            transition: "background 0.3s, border-color 0.3s, transform 0.15s",
            backdropFilter: "blur(12px)",
            boxShadow: isPlaying
              ? "0 0 30px rgba(0,200,255,0.3), inset 0 0 20px rgba(0,200,255,0.05)"
              : "0 0 20px rgba(0,0,0,0.5)",
          }}
          onMouseEnter={(e) => {
            (e.currentTarget as HTMLButtonElement).style.transform = "scale(1.08)";
          }}
          onMouseLeave={(e) => {
            (e.currentTarget as HTMLButtonElement).style.transform = "scale(1)";
          }}
        >
          {isPlaying ? (
            // Pause icon
            <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
              <rect x="6" y="5" width="6" height="18" rx="2" fill="white" opacity="0.9" />
              <rect x="16" y="5" width="6" height="18" rx="2" fill="white" opacity="0.9" />
            </svg>
          ) : (
            // Play icon
            <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
              <path d="M9 5.5L22 14L9 22.5V5.5Z" fill="white" opacity="0.9" />
            </svg>
          )}
        </button>
      </div>

      <p
        style={{
          marginTop: 24,
          color: "rgba(255,255,255,0.35)",
          fontSize: 13,
          letterSpacing: "0.12em",
          textTransform: "uppercase",
        }}
      >
        {isPlaying ? "Now Playing" : "Paused"}
      </p>

      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 0.6; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.1); }
        }
      `}</style>
    </div>
  );
}
