package;

class MonoSynth
{
    private var heldNotes:Array<Int> = new Array<Int>();
    private var sampleRate:Float;

    private var phase:Float = 0.0;
    private var fadeSamples:Int = 4000; // Used for attack and release, just to prevent clicks
    private var positionInFade:Int = 0; // Sample position in the fade
    private var currentNote:Null<Int>;
    private var playing:Bool = false;

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
            if (!playing) positionInFade = 0;
            playing = true;
            // Last note priority
            currentNote = heldNotes[heldNotes.length - 1];
        }
        else {
            playing = false;
        }
        var frequency:Float = (440.0 / 32.0) * Math.pow(2.0, ((currentNote - 9.0) / 12.0));
        for (i in 0...output.channels[0].length) {
            // output.channels[0][i] = Math.sin(phase * Math.PI);
            output.channels[0][i] = phase > 0.1 ? 1.0 : 0.0;
            // Fading in
            if (playing && positionInFade < fadeSamples) {
                output.channels[0][i] *= positionInFade / fadeSamples;
                positionInFade++;
            }
            else if (!playing && positionInFade > 0) {
                output.channels[0][i] *= positionInFade / fadeSamples;
                positionInFade--;
            }
            else if (!playing && positionInFade == 0) {
                currentNote = null;
                break;
            }
            phase += frequency / sampleRate;
            while (phase > 1.0) phase -= 1.0;
        }
    }
}