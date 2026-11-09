import React from 'react';
import { Composition } from 'remotion';
import { Video } from './Video';
import timeline from './timeline.json';

export const Root: React.FC = () => (
  <Composition id="UTS" component={Video} durationInFrames={timeline.total} fps={30} width={1920} height={1080} />
);
