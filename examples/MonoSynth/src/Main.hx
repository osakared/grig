package;

import grig.audio.AudioInterface;
import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import haxe.io.BytesInput;
import haxe.Resource;

#if (target.threaded)
import sys.thread.Mutex;
#end

class Main
{
    var midiIn:MidiIn;
    var audioInterface:AudioInterface;
	var synth:MonoSynth;

    #if (target.threaded)
    var m:Mutex;
    #end

    private inline function guardSynth(f:()->Void):Void
    {
        #if (target.threaded)
        m.acquire();
        #end
        f();
        #if (target.threaded)
        m.release();
        #end
    }
    
    private function audioCallback(input:grig.audio.AudioBuffer, output:grig.audio.AudioBuffer, sampleRate:Float, audioStreamInfo:grig.audio.AudioStreamInfo)
    {
        guardSynth(function() {
            synth.render(output);
        });
    }

    private function midiCallback(midiMessage:MidiMessage, delta:Float)
    {
        guardSynth(function() {
            synth.parseMidi(midiMessage);
        });
    }

    private function initMidi()
    {
        trace(MidiIn.getApis());
        var midiIn_ = new MidiIn(grig.midi.Api.Unspecified);
        midiIn_.setCallback(midiCallback);
        midiIn_.getPorts().handle(function(outcome) {
            switch outcome {
                case Success(ports):
                    trace(ports);
                    midiIn_.openPort(0, 'grig.midi').handle(function(midiOutcome) {
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
    }

    private function initAudio()
    {
        trace(AudioInterface.getApis());
        var audioInterface_ = new AudioInterface();
        var ports = audioInterface_.getPorts();
        var options:grig.audio.AudioInterfaceOptions = {};
        trace(ports.length);
        for (port in ports) {
            if (port.isDefaultOutput) {
                options.outputNumChannels = port.maxOutputChannels;
                options.outputPort = port.portID;
                options.sampleRate = port.defaultSampleRate;
                options.inputNumChannels = 0;
                options.outputLatency = port.defaultLowOutputLatency;
                break;
            }
        }
        audioInterface_.setCallback(audioCallback);
        audioInterface_.openPort(options).handle(function(audioOutcome) {
            switch audioOutcome {
                case Success(_):
                    trace(audioInterface_.isOpen);
                    audioInterface = audioInterface_;
                case Failure(error):
                    trace(error);
            }
        });
    }

	public function new()
    {
        #if (target.threaded)
        m = new Mutex();
        #end
        initMidi();
        initAudio();

        synth = new MonoSynth(44100.0);
        mainLoop();
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
                if (audioInterface != null) audioInterface.closePort(); 
                return;
            }
        }
        #end
    }

    static public function main()
    {
        var synth = new Main();
    }

}