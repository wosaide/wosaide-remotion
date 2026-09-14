import React from 'react';
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {
  BIRD_FILL_PATH,
  BIRD_OUTLINE_PATH,
  BIRD_TRACE_TRANSFORM,
  BIRD_VIEW_BOX,
} from './birdGeometry';

const BLACK = '#242424';
const SILK = '#b8b8b8';

const clamp = {
  extrapolateLeft: 'clamp' as const,
  extrapolateRight: 'clamp' as const,
};

const silkOffset = (frame: number, start: number, speed: number) => {
  const elapsed = Math.max(0, frame - start);
  return -((elapsed * speed) % 1);
};

export const BirdFilamentAnimation: React.FC<{
  transparent?: boolean;
  backgroundColor?: string;
}> = ({transparent = true, backgroundColor = '#ffffff'}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  return (
    <AbsoluteFill
      style={{
        backgroundColor: transparent ? 'transparent' : backgroundColor,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <FilamentBird frame={frame} fps={fps} size="86%" />
    </AbsoluteFill>
  );
};

export const FilamentBird: React.FC<{
  frame: number;
  fps: number;
  size?: number | string;
  celebrate?: boolean;
}> = ({frame, fps, size = 312.5, celebrate = false}) => {

  const outlineDraw = interpolate(frame, [4, 54], [0, 1], {
    ...clamp,
    easing: Easing.inOut(Easing.cubic),
  });
  const fillIn = interpolate(frame, [44, 72], [0, 1], {
    ...clamp,
    easing: Easing.out(Easing.cubic),
  });

  const settle = spring({
    frame: Math.max(0, frame - 72),
    fps,
    durationInFrames: 34,
    config: {damping: 14, mass: 0.7, stiffness: 105},
  });

  const idle = interpolate(frame, [78, 96], [0, 1], clamp);
  const phase = ((frame - 78) / 90) * Math.PI * 2;
  const floatY = idle * Math.sin(phase) * 3.2;
  const floatX = idle * Math.sin(phase * 0.5 + 0.6) * 1.4;
  const breathe = 1 + idle * Math.sin(phase) * 0.0045;
  const settleScale = interpolate(settle, [0, 1], [0.988, 1]);
  const settleRotate = interpolate(settle, [0, 1], [-0.45, 0]);

  const celebrationCycle = celebrate && frame >= 132 ? (frame - 132) % 72 : -1;
  const celebrationLift = celebrationCycle >= 0
    ? interpolate(
        celebrationCycle,
        [0, 6, 13, 22, 34, 48, 72],
        [0, 3, -9, -3, 2, 0, 0],
        clamp,
      )
    : 0;
  const celebrationRotate = celebrationCycle >= 0
    ? interpolate(
        celebrationCycle,
        [0, 13, 28, 48, 72],
        [0, -0.8, 0.55, 0, 0],
        clamp,
      )
    : 0;

  const outlineOut = interpolate(frame, [64, 84], [1, 0], clamp);
  const filamentIn = interpolate(frame, [40, 70], [0, 1], clamp);
  const filamentPulse = 0.42 + Math.sin(phase * 1.4) * 0.08;

  return (
    <div
      style={{
        width: size,
        height: size,
        transform: `translate(${floatX}px, ${floatY + celebrationLift}px) rotate(${settleRotate + celebrationRotate}deg) scale(${settleScale * breathe})`,
        transformOrigin: '50% 58%',
        willChange: 'transform',
      }}
    >
      <svg viewBox={BIRD_VIEW_BOX} width="100%" height="100%" style={{overflow: 'visible'}}>
        <g transform={BIRD_TRACE_TRANSFORM}>
          <path
            d={BIRD_FILL_PATH}
            fill={BLACK}
            opacity={fillIn}
          />

          <path
            d={BIRD_OUTLINE_PATH}
            pathLength={1}
            fill="none"
            stroke={BLACK}
            strokeWidth={16}
            vectorEffect="non-scaling-stroke"
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray={1}
            strokeDashoffset={1 - outlineDraw}
            opacity={outlineOut}
          />

          <g
            fill="none"
            stroke={SILK}
            strokeLinecap="round"
            opacity={filamentIn * filamentPulse}
            style={{filter: 'blur(0.35px)'}}
          >
            <path
              d={BIRD_OUTLINE_PATH}
              pathLength={1}
              strokeWidth={5.5}
              vectorEffect="non-scaling-stroke"
              strokeDasharray="0.028 0.972"
              strokeDashoffset={silkOffset(frame, 46, 0.014)}
            />
            <path
              d={BIRD_OUTLINE_PATH}
              pathLength={1}
              strokeWidth={2}
              vectorEffect="non-scaling-stroke"
              strokeDasharray="0.012 0.988"
              strokeDashoffset={silkOffset(frame, 58, 0.022)}
              opacity={0.78}
            />
          </g>
        </g>
      </svg>
    </div>
  );
};
