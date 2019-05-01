package;

enum Stage
{
    Off;
    Attack;
    Decay;
    Sustain;
    Release;
}

class EnvelopeGenerator
{
    // All in samples, for simplicity except sustain which is level
    private var attack:Int;
    private var decay:Int;
    private var sustain:Float;
    private var release:Int;

    public var level(default, null):Float = 0.0;
    private var position:Int = 0;
    public var stage(default, null):Stage = Off;

    public function new(_attack:Float, _decay:Float, _sustain:Float, _release:Float, sampleRate:Float)
    {
        attack = Math.floor(_attack * sampleRate);
        decay = Math.floor(_decay * sampleRate);
        sustain = _sustain;
        release = Math.floor(_release * sampleRate);
    }

    public function advance(samples:Int)
    {
        if (stage == Off) return;
        position += samples;
        if (stage == Attack) {
            if (position >= attack) {
                stage = Decay;
                position -= attack;
            }
            else {
                level += (1.0 - level) / (attack - position);
            }
        }
        if (stage == Decay) {
            if (position >= decay) {
                stage = Sustain;
                position = 0;
            }
            else {
                level = (1.0 - sustain) * ((decay - position) / decay) + sustain;
            }
        }
        if (stage == Sustain) {
            level = sustain;
        }
        else if (stage == Release) {
            if (position >= release) {
                stage = Off;
                position = 0;
            }
            else {
                level -= level / (release - position);
            }
        }
        if (stage == Off) level = 0.0;
    }

    public function triggerOn():Void
    {
        position = 0;
        stage = Attack;
    }

    public function triggerOff():Void
    {
        position = 0;
        stage = Release;
    }
}