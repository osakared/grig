package;

enum Stage
{
    Attack;
    Sustain;
    Release;
}

class MonoSynth
{
    private var heldNotes:Array<Int> = new Array<Int>();
    private var sampleRate:Float;

    private var phase:Float = 0.0;
    private var phase2:Float = 0.0;
    private var currentNote:Null<Int>;
    private var playing:Bool = false;
    private var stage:Stage = Attack;

    public function new(_sampleRate:Float)
    {
        sampleRate = _sampleRate;
    }

    public function parseMidi(midiMessage:grig.midi.MidiMessage):Void
    {
        if (midiMessage.messageType == NoteOn) {
            heldNotes.push(midiMessage.byte2);
        }
        else if (midiMessage.messageType == NoteOff) {
            heldNotes.remove(midiMessage.byte2);
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
            if (!playing) stage = Attack;
            else stage = Sustain;
            playing = true;
            // Last note priority
            currentNote = heldNotes[heldNotes.length - 1];
        }
        else {
            stage = Release;
            playing = false;
        }
        var frequency:Float = (440.0 / 32.0) * Math.pow(2.0, ((currentNote - 9.0) / 12.0));
        var frequency2:Float = frequency * 1.01;
        for (i in 0...output.channels[0].length) {
            // output.channels[0][i] = Math.sin(phase * Math.PI);
            output.channels[0][i] = phase * 0.7 + phase2 * 0.7;//phase > 0.5 ? 1.0 : 0.0;
            if (stage == Attack) {
                output.channels[0][i] *= i / output.channels[0].length;
            }
            else if (stage == Release) {
                output.channels[0][i] *= (output.channels[0].length - i) / output.channels[0].length;
            }
            phase += frequency / sampleRate;
            phase2 += frequency2 / sampleRate;
            while (phase > 1.0) phase -= 1.0;
            while (phase2 > 1.0) phase2 -= 1.0;
        }
        if (!playing) currentNote = null;
    }
}