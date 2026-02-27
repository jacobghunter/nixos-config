import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import { reloadScss, scssWatcher } from './scss.js';
import { globals } from './globals.js';

export function init() {
    globals();
    scssWatcher();
    reloadScss();

    Audio.maxStreamVolume = 1.05;
}
