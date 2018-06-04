/* TO DO LIST:

- mouse over for on/ off buttons
- print values in post window
- limit values displayed to 2 dp
- Connect these UGens to GUI
- create GUI for Reverb and connect the two


- when all done, create app
Making Standalone Applications
*/

(
//boots server on loading

s = Server.local;
s.waitForBoot({

/* Audio */

(
// Busses


~dryOutput = Bus.audio(s, 2); // output of noise gens

~reverbOut = Bus.audio(s, 2); // output of reverb

~masterOutput = Bus.audio(s, 2); //output of master vol knob


//4 noise generators

(
~bNoise = SynthDef.new(\brownNoise, {
	arg amp=0.1, mFiltFreq=2000, mFiltQ=0, mFiltMode=1, pan=0;
	var sig, env;
	env = Line.kr(0,1,0.5);
	sig = BrownNoise.ar(amp,0) * env;
	sig = BMoog.ar(sig, freq:mFiltFreq, q:mFiltQ, mode:mFiltMode);
	/*sig = Pan2.ar(sig, pos:pan); */
	Out.ar(~dryOutput, sig);
}).add;
);

	//	w = Synth.new(\brownNoise);


(
~gNoise = SynthDef.new(\grayNoise, {
	arg amp=0, mFiltFreq=2000, mFiltQ=0, mFiltMode=1, pan=0;
	var sig, env;
	env = Line.kr(0,1,0.3);
	sig = GrayNoise.ar(amp,0)!2 * env;
	sig = BMoog.ar(sig, freq:mFiltFreq, q:mFiltQ, mode:mFiltMode);
	Out.ar(~dryOutput, sig);
}).add;
);
		// x = Synth.new(\grayNoise);

(
~pNoise = SynthDef.new(\pinkNoise, {
	arg amp=0, mFiltFreq=2000, mFiltQ=0, mFiltMode=1, pan=0;
	var sig, env;
	env = Line.kr(0,1,0.3);
	sig = PinkNoise.ar(amp,0)!2 * env;
	sig = BMoog.ar(sig, freq:mFiltFreq, q:mFiltQ, mode:mFiltMode);
	Out.ar(~dryOutput, sig);
}).add;
);

		// y = Synth.new(\pinkNoise);

(
~wNoise = SynthDef.new(\whiteNoise, {
    arg amp=0, mFiltFreq=2000, mFiltQ=0, mFiltMode=1, pan=0;
	var sig, env;
	env = Line.kr(0,1,0.3);
	sig = WhiteNoise.ar(amp,0)!2 * env;
	sig = BMoog.ar(sig, freq:mFiltFreq, q:mFiltQ, mode:mFiltMode);
	Out.ar(~dryOutput, sig);
}).add;
);

		// z = Synth.new(\whiteNoise);

//reverb unit

(
SynthDef.new(\reverb, {
	arg mix=0.4, roomSize=0.7, damp=1;
	var sig;
	sig = In.ar(~dryOutput, 2);
	sig = FreeVerb.ar(sig, mix:mix, room:roomSize, damp:damp)!2;
	Out.ar(~reverbOut, sig);
}).add;
);

~reverb = Synth(\reverb);

//master volume

(SynthDef(\masterVol, {
			arg amp=0.5;
	var sig, in;
		in = ~reverbOut;
		sig = In.ar(in, 2);
		sig = sig * amp;
		Out.ar(~masterOutput);
	}).add;
);

~master = Synth(\masterVol);
);

/* GUI */

// Main Window
(
~mainBox = Window.new("Noise Box", Rect.new(
	Window.screenBounds.width/2-400,
	Window.screenBounds.height/2-250,
	800,
	500
), resizable: false, scroll:true);
~mainBox.front;
~mainBox.alwaysOnTop_(true);
~mainBox.view.background_(Color.new255(99,184,255));
~mainBox.acceptsMouseOver=true;
	h = NumberBox(~mainBox, 200 @ 30).decimals_(2).background_(Color.new255(255,255,255))
);


// on/off buttons for each generator


(
~brownButton = Button.new(~mainBox, Rect(20,40,60,50))
.states_([
			["off", Color.new255(255,255,255),Color.new255(99,0,0)],
			["on", Color.new255(0,0,0),Color.new255(99,0,0)]
]);
		~brownButton.action_({
			arg obj;
			if(
				obj.value == 1,
				{
					w = Synth.new(\brownNoise);
				},
				{w.free}
			);
		});

~grayButton = Button.new(~mainBox, Rect(20,140,60,50))
.states_([
	["off", Color.new255(255,255,255),Color.new255(186,186,186)],
	["on", Color.new255(0,0,0),Color.new255(186,186,186)]
]);
		~grayButton.action_({
			arg obj;
			if(
				obj.value == 1,
				{
					x = Synth.new(\grayNoise);
				},
				{x.free}
			);
		});

~pinkButton = Button.new(~mainBox, Rect(20,240,60,50))
.states_([
	["off", Color.new255(255,255,255),Color.new255(255,140,244)],
	["on", Color.new255(0,0,0),Color.new255(255,140,244)]
]);
		~pinkButton.action_({
			arg obj;
			if(
				obj.value == 1,
				{
					y = Synth.new(\pinkNoise);
				},
				{y.free}
			);
		});

~whiteButton = Button.new(~mainBox, Rect(20,340,60,50))
.states_([
	["off", Color.new255(186,186,186),Color.new255(255,255,255)],
	["on", Color.new255(0,0,0),Color.new255(255,255,255)]
]);
		~whiteButton.action_({
			arg obj;
			if(
				obj.value == 1,
				{
					z = Synth.new(\whiteNoise);
				},
				{z.free}
			);
		});
);


// volume knobs


(
~bVolKnob = Knob.new(~mainBox, Rect(100,40,50,50));
~bVolKnob.value = 0;
~bVolKnob.action_({|v,x,y,m| h.string = "brown volume: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "brown volume: " ++ v.value.asString; });
		~bVolKnob.action_({
			arg obj;
			var vol;
			vol = obj.value.postln;
			w.set(\amp, vol);
		});
		~bVolKnob.background_(Color.new255(99,0,0));


~gVolKnob = Knob.new(~mainBox, Rect(100,140,50,50));
~gVolKnob.value = 0;
~gVolKnob.action_({|v,x,y,m| h.string = "gray volume: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "gray volume: " ++ v.value.asString;
});
		~gVolKnob.action_({
			arg obj;
			var vol;
			vol = obj.value.postln;
			x.set(\amp, vol);
		});
		~gVolKnob.background_(Color.new255(186,186,186));

~pVolKnob = Knob.new(~mainBox, Rect(100,240,50,50));
~pVolKnob.value = 0;
~pVolKnob.action_({|v,x,y,m| h.string = "pink volume: " ++ v.value.asString; })
		.mouseOverAction_({|v,x,y| h.string = "pink volume: " ++ v.value.asString;
});
		~pVolKnob.action_({
			arg obj;
			var vol;
			vol = obj.value.postln;
			y.set(\amp, vol);
		});
		~pVolKnob.background_(Color.new255(255,140,244));

~wVolKnob = Knob.new(~mainBox, Rect(100,340,50,50));
~wVolKnob.value = 0;
~wVolKnob.action_({|v,x,y,m| h.string = "white volume: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "white volume: " ++ v.value.asString;
});
		~wVolKnob.action_({
			arg obj;
			var vol;
			vol = obj.value.postln;
			z.set(\amp, vol);
		});
);


// pan knobs


(
~bPanKnob = Knob.new(~mainBox, Rect(170,40,50,50));
~bPanKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~bPanKnob.action_({|v,x,y,m| h.string = "brown pan: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "brown pan: " ++ v.value.asString;
});
		~bPanKnob.action_({
			arg obj;
			var pan;
			pan = obj.value.linexp(0,1,-1,1).postln;
			w.set(\pan, pan);
		});
		~bPanKnob.background_(Color.new255(99,0,0));

~gPanKnob = Knob.new(~mainBox, Rect(170,140,50,50));
~gPanKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~gPanKnob.action_({|v,x,y,m| h.string = "gray pan: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "gray pan: " ++ v.value.asString;
});
		~gPanKnob.action_({
			arg obj;
			var pan;
			pan = obj.value.postln;
			x.set(\pan, pan);
		});
		~gPanKnob.background_(Color.new255(186,186,186));

~pPanKnob = Knob.new(~mainBox, Rect(170,240,50,50));
~pPanKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~pPanKnob.action_({|v,x,y,m| h.string = "pink pan: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "pink pan: " ++ v.value.asString;
});
		~pPanKnob.action_({
			arg obj;
			var pan;
			pan = obj.value.postln;
			y.set(\pan, pan);
		});
		~pPanKnob.background_(Color.new255(255,140,244));

~wPanKnob = Knob.new(~mainBox, Rect(170,340,50,50));
~wPanKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~wPanKnob.action_({|v,x,y,m| h.string = "white pan: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "white pan: " ++ v.value.asString;
});
		~wPanKnob.action_({
			arg obj;
			var pan;
			pan = obj.value.postln;
			z.set(\pan, pan);
		});
);



//filter Freq knobs


(
~bFilterFreqKnob = Knob.new(~mainBox, Rect(240,40,50,50))
     .action_({|v,x,y,m| h.string = "brown filter freq: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "brown filter freq: " ++ v.value.asString; });
		~bFilterFreqKnob.action_({
			arg obj;
			var filtFreq;
			filtFreq = obj.value.linexp(0,1,440,8000).postln;
			w.set(\mFiltFreq, filtFreq);
		});
		~bFilterFreqKnob.background_(Color.new255(99,0,0));


~gFilterFreqKnob = Knob.new(~mainBox, Rect(240,140,50,50))
     .action_({|v,x,y,m| h.string = "gray filter freq: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "gray filter freq: " ++ v.value.asString;
});
		~gFilterFreqKnob.action_({
			arg obj;
			var filtFreq;
			filtFreq = obj.value.linexp(0,1,440,8000).postln;
			x.set(\mFiltFreq, filtFreq);
		});
		~gFilterFreqKnob.background_(Color.new255(186,186,186));

~pFilterFreqKnob = Knob.new(~mainBox, Rect(240,240,50,50))
     .action_({|v,x,y,m| h.string = "pink filter freq: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "pink filter freq: " ++ v.value.asString;
});
		~pFilterFreqKnob.action_({
			arg obj;
			var filtFreq;
			filtFreq = obj.value.linexp(0,1,440,8000).postln;
			y.set(\mFiltFreq, filtFreq);
		});
		~pFilterFreqKnob.background_(Color.new255(255,140,244));

~wFilterFreqKnob = Knob.new(~mainBox, Rect(240,340,50,50))
     .action_({|v,x,y,m| h.string = "white filter freq: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "white filter freq: " ++ v.value.asString;
});
		~wFilterFreqKnob.action_({
			arg obj;
			var filtFreq;
			filtFreq = obj.value.linexp(0,1,440,8000).postln;
			z.set(\mFiltFreq, filtFreq);
		});
);


//filter Q knobs


(
~bFilterQKnob = Knob.new(~mainBox, Rect(310,40,50,50));
~bFilterQKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~bFilterQKnob.action_({|v,x,y,m| h.string = "brown filter Q: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "brown filter Q: " ++ v.value.asString;
});
		~bFilterQKnob.action_({
			arg obj;
			var filtQ;
			filtQ = obj.value.postln;
			w.set(\mFiltQ, filtQ);
		});
		~bFilterQKnob.background_(Color.new255(99,0,0));

~gFilterQKnob = Knob.new(~mainBox, Rect(310,140,50,50));
~gFilterQKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~gFilterQKnob.action_({|v,x,y,m| h.string = "gray filter Q: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "gray filter Q: " ++ v.value.asString;
});
		~gFilterQKnob.action_({
			arg obj;
			var filtQ;
			filtQ = obj.value.postln;
			x.set(\mFiltQ, filtQ);
		});
		~gFilterQKnob.background_(Color.new255(186,186,186));

~pFilterQKnob = Knob.new(~mainBox, Rect(310,240,50,50));
~pFilterQKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~pFilterQKnob.action_({|v,x,y,m| h.string = "pink filter Q: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "pink filter Q: " ++ v.value.asString;
});
		~pFilterQKnob.action_({
			arg obj;
			var filtQ;
			filtQ = obj.value.postln;
			y.set(\mFiltQ, filtQ);
		});
		~pFilterQKnob.background_(Color.new255(255,140,244));

~wFilterQKnob = Knob.new(~mainBox, Rect(310,340,50,50));
~wFilterQKnob.action_({|v,x,y,m| \pan.asSpec.map(v.value).postln; })
    .centered_(false)
    .value_(\pan.asSpec.unmap(0));
~wFilterQKnob.action_({|v,x,y,m| h.string = "white filter Q: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "white filter Q: " ++ v.value.asString;
});
		~wFilterQKnob.action_({
			arg obj;
			var filtQ;
			filtQ = obj.value.postln;
			z.set(\mFiltQ, filtQ);
		});

);


// filter mode PopUpMenus


(
~bFilterMode = PopUpMenu(~mainBox, Rect.new(380,50,100,25));
~bFilterMode.items = ["low pass", "high pass", "band pass"];
~bFilterMode.action = { arg menu;
			["brown", menu.item].postln;
};
		~bFilterMode.action_({
			arg obj;
			if(
				obj.value == 0,
				{
					w.set(\mFiltMode, 1);
				},
				obj.value ==1, {
					w.set(\mFiltMode, 2);
				},
				obj.value ==2, {
					w.set(\mFiltMode, 3);
				},
			);
		});
		~bFilterMode.background_(Color.new255(99,0,0));

~gFilterMode = PopUpMenu(~mainBox, Rect.new(380,150,100,25));
~gFilterMode.items = ["low pass", "high pass", "band pass"];
~gFilterMode.action = { arg menu;
			["gray", menu.item].postln;
};
		~gFilterMode.background_(Color.new255(186,186,186));

~pFilterMode = PopUpMenu(~mainBox, Rect.new(380,250,100,25));
~pFilterMode.items = ["low pass", "high pass", "band pass"];
~pFilterMode.action = { arg menu;
			["pink", menu.item].postln;
};
		~pFilterMode.background_(Color.new255(255,140,244));

~wFilterMode = PopUpMenu(~mainBox, Rect.new(380,350,100,25));
~wFilterMode.items = ["low pass", "high pass", "band pass"];
~wFilterMode.action = { arg menu;
			["white", menu.item].postln;
};
);

//reverb send knobs

(
~bReverbSendKnob = Knob.new(~mainBox, Rect(500,40,50,50));
~bReverbSendKnob.action_({|v,x,y,m| h.string = "brown reverb level: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "brown reverb level: " ++ v.value.asString;
});
		~bReverbSendKnob.background_(Color.new255(99,0,0));

~gReverbSendKnob = Knob.new(~mainBox, Rect(500,140,50,50));
~gReverbSendKnob.action_({|v,x,y,m| h.string = "gray reverb level: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "gray reverb level: " ++ v.value.asString;
});
		~gReverbSendKnob.background_(Color.new255(186,186,186));

~pReverbSendKnob = Knob.new(~mainBox, Rect(500,240,50,50));
~pReverbSendKnob.action_({|v,x,y,m| h.string = "pink reverb level: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "pink reverb level: " ++ v.value.asString;
});
		~pReverbSendKnob.background_(Color.new255(255,140,244));

~wReverbSendKnob = Knob.new(~mainBox, Rect(500,340,50,50));
~wReverbSendKnob.action_({|v,x,y,m| h.string = "white reverb level: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "white reverb level: " ++ v.value.asString;
});

);

//reverb section

(
~reverbMix = Knob.new(~mainBox, Rect(580, 40, 50, 50));
~reverbMix.action_({|v,x,y,m| h.string = "reverb mix level: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "reverb mix level: " ++ v.value.asString;
});

~reverbRoomSize = Knob.new(~mainBox, Rect(650, 40, 50, 50));
~reverbRoomSize.action_({|v,x,y,m| h.string = "reverb room size level: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "reverb room size level: " ++ v.value.asString;
});

~reverbHFDamp = Knob.new(~mainBox, Rect(580, 110, 50, 50));
~reverbHFDamp.value = 1;
~reverbHFDamp.action_({|v,x,y,m| h.string = "reverb HF Damping: " ++ v.value.asString; })
     .mouseOverAction_({|v,x,y| h.string = "reverb HF Damping: " ++ v.value.asString;

});

);

//panic button

(
		~panicButton = Button.new(~mainBox, Rect(700,275,70,50))
		.states_([
			["panic!",Color.new255(0,0,0),Color.new255(255,0,0)]
		]);
	);
	~panicButton.action_({
			arg obj;
			if(
				obj.value == 0,
				{
					s.freeAll;
				}
			);
	});


//master volume

(
~masterVolKnob = Knob.new(~mainBox, Rect(610,200,85,85));
~masterVolKnob.value = 0.5;
~masterVolKnob.action_({|v,x,y,m| h.string = "master volume level: " ++ v.value.asString; })
		.mouseOverAction_({|v,x,y| h.string = "master volume level: " ++ v.value.asString;});

);

//output FreqScope

(
~outScope = FreqScopeView.new(~mainBox, Rect.new(~mainBox.bounds.width/1.4,
	~mainBox.bounds.height/1.5,
	200,
	140),
s);
~outScope.active_(true);
~mainBox.onClose({~outScope.kill});
);

});

)







