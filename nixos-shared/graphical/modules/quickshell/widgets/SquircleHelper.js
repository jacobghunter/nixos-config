.pragma library

/**
 * Dynamically maps a superellipse/squircle rounding power to Bezier control point tension.
 * Matches the logic from Squircle.qml.
 * 
 * @param {number} roundingPower The power (e.g. 2 for circle, 4 for true squircle).
 * @returns {number} The Bezier tension value.
 */
function getTension(roundingPower) {
    switch (roundingPower) {
        case 2: return 0.552; // Standard circle
        case 3: return 0.783; // Smooth corner
        case 4: return 0.909; // True squircle
        case 5: return 0.950; // Sharp squircle
        case 6: return 0.970; 
        case 7: return 0.982; 
        case 8: return 0.990; 
        case 9: return 0.995; 
        case 10: return 0.998; 
        default: return 0.552; 
    }
}
