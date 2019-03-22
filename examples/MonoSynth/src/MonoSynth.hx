package;

import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import grig.synth.fmsynth.FMSynth;
import haxe.io.BytesInput;
import haxe.Resource;

class MonoSynth
{
    var midiIn:MidiIn;
	var synth:FMSynth;

	public function new()
    {
		// synth = new FMSynth(44100.0, 8, 8);
        trace(MidiIn.getApis());
        var midiIn_ = new MidiIn(grig.midi.Api.Unspecified);
        midiIn_.setCallback(function (midiMessage:MidiMessage, delta:Float) {
            trace(midiMessage.messageType);
            trace(delta);
        });
        midiIn_.getPorts().handle(function(outcome) {
            switch outcome {
                case Success(ports):
                    trace(ports);
                    midiIn_.openPort(1, 'grig.midi').handle(function(midiOutcome) {
                        switch midiOutcome {
                            case Success(_):
                                trace('Started midi input');
                                midiIn = midiIn_;
                            case Failure(error):
                                trace(error);
                        }
                    });
                case Failure(error):
                    trace(error);
            }
        });
        mainLoop();
	}

	public function loadPatch(name:String)
	{
		var patchBytes = Resource.getBytes(name);
        synth.loadLibFMSynthPreset(new BytesInput(patchBytes));
	}

    private function mainLoop()
    {
        #if (sys && !nodejs)
        var stdout = Sys.stdout();
        var stdin = Sys.stdin();
        // Using Sys.getChar() unfortunately fucks up the output
        stdout.writeString('quit[enter] to quit\n');
        while (true) {
            var command = stdin.readLine();
            if (command.toLowerCase() == 'quit') {
                if (midiIn != null) midiIn.closePort();
                return;
            }
        }
        #end
    }

    static public function main()
    {
        var monoSynth = new MonoSynth();
    }

	// override function onSample( buf : haxe.io.Float32Array ) {
	// 	if (left == null || left.length != buf.length) {
	// 		left = new AudioChannel(buf.length, 44100);
	// 		right = new AudioChannel(buf.length, 44100);
	// 	}
	// 	else {
	// 		left.clear();
	// 		right.clear();
	// 	}
	// 	synth.render(left, right);
	// 	for( i in 0...buf.length ) {
	// 		buf[i] = left.get(i);
	// 	}
	// }

	// public function noteOn(note:Int, velocity:Int = 64)
	// {
	// 	synth.noteOn(note, velocity);
	// }

	// public function noteOff(note:Int)
	// {
	// 	synth.noteOff(note);
	// }

}