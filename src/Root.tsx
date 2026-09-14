import React from 'react';
import {Composition} from 'remotion';
import {BrandAnimation} from './brand/BrandAnimation';
import {BirdFilamentAnimation} from './brand/BirdFilamentAnimation';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="WOSAideBrand"
        component={BrandAnimation}
        durationInFrames={360}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{transparent: false}}
      />
      <Composition
        id="WOSAideBrandTransparent"
        component={BrandAnimation}
        durationInFrames={360}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{transparent: true}}
      />
      <Composition
        id="WOSAideBrandIdleTransparent"
        component={BrandAnimation}
        durationInFrames={90}
        fps={30}
        width={640}
        height={320}
        defaultProps={{
          transparent: false,
          frameOffset: 124,
          logoScale: 0.54,
          backgroundColor: '#ffffff',
        }}
      />
      <Composition
        id="WOSAideWelcome"
        component={BrandAnimation}
        durationInFrames={294}
        fps={30}
        width={640}
        height={320}
        defaultProps={{
          transparent: false,
          frameOffset: 0,
          logoScale: 0.50,
          backgroundColor: '#ffffff',
          welcome: true,
          version: '1.0.5',
        }}
      />
      <Composition
        id="BirdFilament"
        component={BirdFilamentAnimation}
        durationInFrames={180}
        fps={30}
        width={1254}
        height={1254}
        defaultProps={{transparent: true}}
      />
    </>
  );
};
