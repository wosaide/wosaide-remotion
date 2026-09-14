import React from 'react';
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {FilamentBird} from './BirdFilamentAnimation';

const BLACK = '#242424';
const GOLD = '#ffb728';

const clamp = {
  extrapolateLeft: 'clamp' as const,
  extrapolateRight: 'clamp' as const,
};

const IDLE_START_FRAME = 124;
const IDLE_LOOP_FRAMES = 90;

const getIdleState = (frame: number) => {
  const active = frame >= IDLE_START_FRAME;
  const loopFrame = active ? (frame - IDLE_START_FRAME) % IDLE_LOOP_FRAMES : 0;
  const phase = (loopFrame / IDLE_LOOP_FRAMES) * Math.PI * 2;
  const blend = interpolate(
    frame,
    [IDLE_START_FRAME, IDLE_START_FRAME + 12],
    [0, 1],
    clamp,
  );

  return {active, loopFrame, phase, blend};
};

const laurelPath =
  'M226.098 649.152C207.598 647.652 184.598 652.902 169.098 662.402C162.598 665.902 161.848 671.652 167.348 676.652C181.848 689.902 203.848 699.652 222.348 700.902C241.848 703.402 265.098 697.402 280.848 685.652C285.598 682.152 286.098 677.152 281.348 672.902C267.598 659.902 245.348 650.402 226.098 649.152ZM294.348 540.152C284.348 556.152 278.348 579.152 279.348 597.402C280.348 616.652 289.348 638.902 301.848 652.902C305.848 657.652 310.598 657.652 314.598 652.652C326.848 637.902 333.598 614.652 331.598 594.652C330.348 576.152 321.098 554.152 308.348 539.152C303.598 533.652 298.348 534.152 294.348 540.152ZM135.098 561.902C117.348 555.402 93.3479 554.902 75.5979 560.152C69.0979 562.152 67.3479 567.402 70.8479 573.402C81.3479 589.902 100.098 604.902 117.848 611.152C135.848 618.402 160.098 618.402 178.348 610.902C183.848 608.902 185.348 604.152 182.348 598.902C171.848 582.402 153.098 567.902 135.098 561.902ZM228.598 473.902C214.848 486.402 203.098 507.152 199.598 525.152C195.598 544.402 198.348 568.402 206.848 584.652C209.348 590.152 214.348 591.152 219.098 587.652C234.598 576.402 246.848 555.652 250.348 535.902C253.848 517.402 250.598 493.652 242.098 476.402C239.348 469.652 233.848 468.652 228.598 473.902ZM0.34787 436.152C3.09787 454.902 14.3479 476.652 27.8479 490.152C41.3479 504.152 63.3479 513.652 83.0979 514.152C89.0979 514.652 92.3479 510.652 91.5979 504.652C88.3479 485.152 77.0979 464.152 63.3479 451.902C49.8479 438.902 28.5979 428.652 9.84787 426.152C3.09787 425.402-0.90213 429.152 0.34787 436.152ZM184.598 409.152C167.348 414.902 148.348 429.152 137.098 444.402C125.848 459.402 118.848 482.152 119.848 501.902C120.098 507.902 124.098 510.902 130.098 509.652C149.348 505.152 169.348 491.402 179.598 475.152C190.348 458.652 197.098 435.652 196.098 417.152C196.098 409.902 191.598 406.652 184.598 409.152ZM131.098 333.402C116.098 345.402 103.598 366.152 99.8479 384.902C98.5979 390.402 101.848 394.652 107.598 394.902C127.348 395.402 150.098 386.902 164.348 373.902C178.598 361.652 191.348 340.902 195.598 321.902C196.598 315.402 192.848 311.152 186.348 311.402C167.098 312.902 145.098 321.402 131.098 333.402ZM0.84787 290.902C-1.40213 309.152 4.09787 332.652 14.0979 349.652C23.8479 366.902 42.5979 381.902 60.8479 387.152C66.5979 388.902 71.0979 385.902 71.8479 379.902C73.8479 361.652 68.5979 338.152 58.0979 321.402C47.8479 305.402 29.5979 290.152 12.8479 283.652C6.34787 280.652 1.59787 283.402 0.84787 290.902ZM148.598 225.152C130.348 231.402 111.348 246.152 101.348 262.402C98.0979 267.402 99.8479 272.402 105.098 274.902C123.098 282.402 147.348 282.402 165.598 274.652C184.348 267.402 203.098 252.152 212.598 236.152C216.098 230.402 214.098 225.652 207.598 223.402C189.598 218.152 165.848 218.652 148.598 225.152ZM40.8479 140.152C32.3479 157.902 29.0979 181.902 32.8479 200.152C36.0979 219.402 48.5979 240.152 64.3479 251.402C68.8479 255.152 73.8479 253.652 76.8479 248.402C85.3479 231.402 88.0979 207.902 83.8479 189.152C79.8479 170.652 68.0979 149.902 54.5979 137.402C49.3479 133.152 43.8479 134.152 40.8479 140.152ZM206.848 131.902C187.598 135.652 167.098 147.902 155.348 162.402C151.598 166.902 152.598 171.652 157.598 174.902C174.098 185.152 198.098 188.152 217.098 183.152C236.098 178.902 256.848 166.402 269.098 152.152C273.598 146.902 272.348 141.402 266.098 138.652C249.098 131.152 225.598 128.402 206.848 131.902ZM112.098 32.6521C101.348 48.9021 94.8479 72.1521 96.0979 90.6521C96.3479 109.902 106.098 132.152 119.848 146.402C124.598 150.652 129.598 150.152 133.098 145.152C143.598 128.652 149.848 105.402 148.348 87.1521C147.098 68.6521 138.098 46.9021 126.098 31.9021C121.348 26.6521 115.848 27.1521 112.098 32.6521ZM277.848 0.152063C259.098 3.15206 238.098 14.1521 224.848 27.4021C211.348 40.6521 200.848 62.4021 198.598 81.1521C198.098 87.1521 201.348 90.6521 207.348 90.4021C226.848 89.4021 248.598 78.9021 261.848 64.1521C274.598 50.9021 285.098 29.1521 288.098 10.1521C288.848 3.15206 285.098-0.847937 277.848 0.152063Z';

const laurelLeaves = laurelPath.match(/M[^Z]+Z/g) ?? [];
const laurelLeavesBottomUp = [...laurelLeaves].sort((a, b) => {
  const getStartY = (path: string) => Number(path.match(/^M[\d.]+ ([\d.]+)/)?.[1] ?? 0);
  return getStartY(b) - getStartY(a);
});

const starPath =
  'M316.9 18C311.6 7.3 300.7 0 288.7 0S265.8 7.3 260.5 18L195 150.3 49.1 171.5C37.3 173.2 27.5 181.5 23.8 192.9S23.3 216.7 31.9 225L137.5 328 112.6 473.4C110.6 485.2 115.5 497.2 125.2 504.3S147.7 512.3 158.3 506.7L288.7 438.1 419 506.5C429.6 512.1 442.3 511.1 452 504S466.6 485 464.6 473.2L439.7 328 545.2 225C553.8 216.7 556.9 204.3 553.2 192.9S539.8 173.2 528 171.5L382.1 150.3 316.9 18Z';

const Laurel: React.FC<{
  frame: number;
  fps: number;
  side: 'left' | 'right';
}> = ({frame, fps, side}) => {
  const isLeft = side === 'left';
  const {active: idleActive, phase: idlePhase, blend: idleBlend} = getIdleState(frame);
  const delay = isLeft ? 0 : 2;
  const settle = spring({
    frame: Math.max(0, frame - delay - 30),
    fps,
    durationInFrames: 34,
    config: {damping: 16, mass: 0.8, stiffness: 95},
  });

  const idleSway = idleActive
    ? idleBlend * (
        Math.sin(idlePhase + (isLeft ? 0 : Math.PI)) * 0.92 +
        Math.sin(idlePhase * 2 + (isLeft ? 0.35 : -0.35)) * 0.16
      )
    : 0;
  const rotation =
    interpolate(settle, [0, 1], [isLeft ? -3.5 : 3.5, 0]) + idleSway;
  const x = interpolate(settle, [0, 1], [isLeft ? -10 : 10, 0]);
  const idleBreath = idleActive
    ? 1 + idleBlend * Math.sin(idlePhase + (isLeft ? 0 : 0.28)) * 0.006
    : 1;
  const overallScale = idleBreath;

  return (
    <div
      style={{
        width: 164.9,
        height: 350,
        transform: `translateX(${x}px) rotate(${rotation}deg) scale(${overallScale})`,
        transformOrigin: isLeft ? '82% 100%' : '18% 100%',
        willChange: 'transform, opacity',
      }}
    >
      <svg viewBox="0 0 331.946 703.554" width="100%" height="100%" style={{overflow: 'visible'}}>
        <g transform={isLeft ? undefined : 'translate(331.946 0) scale(-1 1)'}>
          {laurelLeavesBottomUp.map((leafPath, index) => {
            const leafStart = delay + index * 4;
            const leafGrow = spring({
              frame: Math.max(0, frame - leafStart),
              fps,
              durationInFrames: 16,
              config: {damping: 12, mass: 0.42, stiffness: 190},
            });
            const leafOpacity = interpolate(leafGrow, [0, 0.12, 1], [0, 0.5, 1], clamp);
            const leafScale = interpolate(leafGrow, [0, 1], [0.06, 1]);
            const leafLift = interpolate(leafGrow, [0, 1], [24, 0]);
            const leafRotate = interpolate(
              leafGrow,
              [0, 1],
              [isLeft ? -8 : 8, 0],
            );

            return (
              <path
                key={`${side}-${index}`}
                d={leafPath}
                fill={BLACK}
                opacity={leafOpacity}
                style={{
                  transformBox: 'fill-box',
                  transformOrigin: '50% 100%',
                  transform: `translateY(${leafLift}px) scale(${leafScale}) rotate(${leafRotate}deg)`,
                }}
              />
            );
          })}
        </g>
      </svg>
    </div>
  );
};

const Star: React.FC<{
  frame: number;
  fps: number;
  index: number;
  crisp?: boolean;
}> = ({frame, fps, index, crisp = false}) => {
  const {active: idleActive, phase: idlePhase, blend: idleBlend} = getIdleState(frame);
  const distanceFromCenter = Math.abs(index - 2);
  const side = index === 2 ? 0 : index < 2 ? -1 : 1;
  const start = 48 + distanceFromCenter * 9;
  const enter = spring({
    frame: Math.max(0, frame - start),
    fps,
    durationInFrames: 24,
    config: {damping: 9, mass: 0.55, stiffness: 170},
  });
  const sizes = [0.72, 0.86, 1.08, 0.86, 0.72];
  const offsets = [13, 6.5, 0, 6.5, 13];
  const base = 45.7;
  const idlePulse = idleActive
    ? 1 + idleBlend * Math.sin(idlePhase + distanceFromCenter * 0.28) * 0.035
    : 1;
  const scale = sizes[index] * enter * idlePulse;
  const opacity = interpolate(frame, [start, start + 8], [0, 1], clamp);
  const introX = (1 - enter) * side * -11 * distanceFromCenter;
  const introBobEnvelope = interpolate(
    frame,
    [start + 22, start + 28, IDLE_START_FRAME - 10, IDLE_START_FRAME],
    [0, 1, 1, 0],
    clamp,
  );
  const introBob = frame > start + 22
    ? Math.sin((frame + distanceFromCenter * 8) / 16) * 2.2 * introBobEnvelope
    : 0;
  const idleBob = idleActive
    ? idleBlend * Math.sin(idlePhase + distanceFromCenter * 0.42) * 1.8
    : 0;
  const bob = introBob + idleBob;
  const shimmer = 0.16 + (idleActive
    ? idleBlend * (0.08 + (Math.sin(idlePhase + distanceFromCenter * 0.36) + 1) * 0.08)
    : 0);

  return (
    <div
      style={{
        width: base,
        height: base,
        opacity,
        transform: `translate(${introX}px, ${offsets[index] + bob + (1 - enter) * 34}px) scale(${scale}) rotate(${(1 - enter) * side * 12}deg)`,
        transformOrigin: '50% 50%',
        filter: crisp ? 'none' : `drop-shadow(0 0 ${5 + shimmer * 9}px rgba(255,183,40,${shimmer}))`,
        willChange: 'transform, opacity',
      }}
    >
      <svg viewBox="0 0 576 512" width="100%" height="100%">
        <path d={starPath} fill={GOLD} />
      </svg>
    </div>
  );
};

export const BrandAnimation: React.FC<{
  transparent: boolean;
  frameOffset?: number;
  logoScale?: number;
  backgroundColor?: string;
  welcome?: boolean;
  version?: string;
}> = ({
  transparent,
  frameOffset = 0,
  logoScale = 1,
  backgroundColor = '#fbfbfa',
  welcome = false,
  version = '1.0.5',
}) => {
  const frame = useCurrentFrame() + frameOffset;
  const {fps} = useVideoConfig();

  const sceneIn = interpolate(frame, [0, 16], [0, 1], {
    ...clamp,
    easing: Easing.out(Easing.cubic),
  });
  const settle = interpolate(frame, [95, 122], [0, 1], {
    ...clamp,
    easing: Easing.inOut(Easing.quad),
  });
  const logoLift = interpolate(settle, [0, 1], [5, 0]);
  const sceneScale = interpolate(sceneIn, [0, 1], [0.96, 1]);
  const welcomeLogoLift = welcome ? -5 : 0;

  const revealText = (start: number, end: number, distance: number, blur: number) => {
    const progress = interpolate(frame, [start, end], [0, 1], {
      ...clamp,
      easing: Easing.out(Easing.cubic),
    });
    return {
      opacity: progress,
      transform: `translateY(${interpolate(progress, [0, 1], [distance, 0])}px)`,
      filter: `blur(${interpolate(progress, [0, 1], [blur, 0])}px)`,
    };
  };

  const welcomeLabelStyle = revealText(94, 110, 7, 0);
  const welcomeTitleStyle = revealText(104, 120, 10, 0);
  const welcomeVersionStyle = revealText(112, 128, 8, 0);

  return (
    <AbsoluteFill
  style={{
    backgroundColor: transparent ? 'transparent' : backgroundColor,
    overflow: 'hidden',
  }}>
      {!transparent ? null : null}

      <AbsoluteFill style={{alignItems: 'center', justifyContent: 'center'}}>
        <div
          style={{
            position: 'relative',
            width: 1000,
            height: 512.5,
            opacity: sceneIn,
            transform: `translateY(${logoLift + welcomeLogoLift}px) scale(${sceneScale * logoScale})`,
            transformOrigin: '50% 50%',
          }}
        >
          <div style={{position: 'absolute', left: welcome ? 70 : 109.1, top: 34.4}}>
            <Laurel frame={frame} fps={fps} side="left" />
          </div>

          <div style={{position: 'absolute', left: 343.75, top: 53.1}}>
            <FilamentBird frame={frame} fps={fps} celebrate={welcome} />
          </div>

          <div style={{position: 'absolute', right: welcome ? 70 : 109.1, top: 34.4}}>
            <Laurel frame={frame} fps={fps} side="right" />
          </div>

          <div
            style={{
              position: 'absolute',
              left: '50%',
              top: welcome ? 385 : 397,
              display: 'flex',
              gap: welcome ? 24 : 31.25,
              alignItems: 'flex-start',
              transform: `translateX(-50%) ${welcome ? 'scale(1.08)' : ''}`,
              transformOrigin: '50% 50%',
            }}
          >
            {[0, 1, 2, 3, 4].map((index) => (
              <Star key={index} frame={frame} fps={fps} index={index} crisp={welcome} />
            ))}
          </div>
        </div>
      </AbsoluteFill>

      {welcome ? (
        <div
          style={{
            position: 'absolute',
            top: 12,
            left: 0,
            right: 0,
            ...welcomeLabelStyle,
            color: '#6e6e73',
            fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Display", "Helvetica Neue", Arial, sans-serif',
            fontSize: 19.5,
            fontWeight: 650,
            letterSpacing: -0.35,
            lineHeight: 1.2,
            textAlign: 'center',
            WebkitFontSmoothing: 'antialiased',
          }}
        >
          Welcome to
        </div>
      ) : null}

      {welcome ? (
        <div
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            bottom: 0,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            color: '#1d1d1f',
            fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Display", "Helvetica Neue", Arial, sans-serif',
            textAlign: 'center',
            WebkitFontSmoothing: 'antialiased',
          }}
        >
          <div
            style={{
              ...welcomeTitleStyle,
              fontSize: 25,
              fontWeight: 650,
              letterSpacing: -0.72,
              lineHeight: 1.08,
            }}
          >
            Web of Science
          </div>
          <div
            style={{
              ...welcomeVersionStyle,
              marginTop: 5,
              color: '#6e6e73',
              fontSize: 15,
              fontWeight: 500,
              letterSpacing: -0.12,
              lineHeight: 1.2,
            }}
          >
            Aide v{version}
          </div>
        </div>
      ) : null}
    </AbsoluteFill>
  );
};
