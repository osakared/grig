package;

import grig.audio.AudioInterface;
import grig.midi.MidiIn;
import grig.midi.MidiMessage;
import grig.synth.fmsynth.FMSynth;
import haxe.io.BytesInput;
import haxe.Resource;

class MonoSynth
{
    var midiIn:MidiIn;
    var audioInterface:AudioInterface;
	var synth:FMSynth;
    
    private function audioCallback(input:grig.audio.AudioBuffer, output:grig.audio.AudioBuffer, sampleRate:Float, audioStreamInfo:grig.audio.AudioStreamInfo)
    {
        synth.render(output.channels[0], output.channels[1]);
    }

    private function midiCallback(midiMessage:MidiMessage, delta:Float)
    {
        synth.parseMidi(midiMessage.toBytes());
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
            }
            break;
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
        initMidi();
        initAudio();

        synth = new FMSynth(44100.0, 8, 8);
        loadPatch('lead_pad.fmp');
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
                if (audioInterface != null) audioInterface.closePort(); 
                return;
            }
        }
        #end
    }

    static public function main()
    {
        var monoSynth = new MonoSynth();
    }

}