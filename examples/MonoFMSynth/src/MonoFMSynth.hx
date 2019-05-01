package;

import grig.midi.MidiMessage;

typedef NoteInfo = {
    pitch:Int,
    velocity:Int
};

class MonoFMSynth
{
    private var heldNotes = new Array<NoteInfo>();
    private var sampleRate:Float;

    private var phase1:Float = 0.0;
    private var phase2:Float = 0.0;
    private var currentNote:Null<NoteInfo>;
    private var playing:Bool = false;
    private var ampEG:EnvelopeGenerator;
    private var modEG:EnvelopeGenerator;

    public function new(_sampleRate:Float)
    {
        sampleRate = _sampleRate;
        ampEG = new EnvelopeGenerator(0.01, 0.0, 1.0, 0.2, sampleRate);
        modEG = new EnvelopeGenerator(0.0, 0.2, 0.5, 0.3, sampleRate);
    }

    public function parseMidi(midiMessage:MidiMessage):Void
    {
        if (midiMessage.messageType == NoteOn) {
            heldNotes.push({pitch: midiMessage.byte2, velocity: midiMessage.byte3});
        }
        else if (midiMessage.messageType == NoteOff) {
            for (i in 0...heldNotes.length) {
                if (heldNotes[i].pitch == midiMessage.byte2) {
                    heldNotes.splice(i, 1);
                    break;
                }
            }
        }
    }

    public function render(output:grig.audio.AudioBuffer):Void
    {
        output.clear();
        if (heldNotes.length == 0 && currentNote == null) {
            return;
        }
        if (output.channels.length == 0) {
            return;
        }
        if (heldNotes.length > 0) {
            if (!playing) {
                ampEG.triggerOn();
                modEG.triggerOn();
            }
            playing = true;
            // Last note priority
            currentNote = heldNotes[heldNotes.length - 1];
        }
        else {
            if (playing) {
                ampEG.triggerOff();
                modEG.triggerOff();
            }
            playing = false;
        }
        var frequency:Float = (440.0 / 32.0) * Math.pow(2.0, ((currentNote.pitch - 9.0) / 12.0));
        var frequency2:Float = frequency * 8.0;
        var frequency1:Float = 0.0;
        for (i in 0...output.channels[0].length) {
            frequency1 = frequency + Math.sin(phase2 * 2.0 * Math.PI) * 500.0 * modEG.level;
            output.channels[0][i] = Math.sin(phase1 * 2.0 * Math.PI) * 0.8 * ampEG.level;
            ampEG.advance(1);
            modEG.advance(1);
            phase1 += frequency1 / sampleRate;
            phase2 += frequency2 / sampleRate;
            while (phase1 > 1.0) phase1 -= 1.0;
            while (phase2 > 1.0) phase2 -= 1.0;
        }
        if (ampEG.stage == Off) currentNote = null;
    }
}