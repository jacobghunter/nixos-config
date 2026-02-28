import QuickSettings from './quicksettings/QuickSettings.js';
import { init } from './settings/setup.js';
import options from './options.js';

const windows = () => [
    QuickSettings(),
];

export default {
    onConfigParsed: init,
    windows: windows().flat(1),
    closeWindowDelay: {
        'quicksettings': options.transition.value,
    },
};
