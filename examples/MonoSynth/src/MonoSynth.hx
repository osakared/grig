package;

class MonoSynth
{
    private var heldNotes:Array<Int> = new Array<Int>();
    private var sampleRate:Float;
    private var phase:Float = 0.0;

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
        if (heldNotes.length == 0) {
            output.clear();
            return;
        }
        if (output.channels.length == 0) {
            return;
        }
        // High note priority
        heldNotes.sort(function(x, y):Int {
            if (x < y) return 1;
            else if (x > y) return -1;
            else return 0;
        });
        var frequency:Float = (440.0 / 32.0) * Math.pow(2.0, ((heldNotes[0] - 9.0) / 12.0));
        for (i in 0...output.channels[0].length) {
            output.channels[0][i] = Math.sin(phase * Math.PI);
            phase += frequency / sampleRate;
        }
    }
}