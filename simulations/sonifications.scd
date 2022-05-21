
(
Project.startup(s, rootPath: "".resolveRelative,  onBoot: {
	f = FX.new(s, outbus: 0);
	v = Ndef(\sonification, { DC.ar([0.0, 0.0]) });
	f.unit(\verb, 2, "sonification() lpf(co10000 cv5000) rev()");
});
)


OSCdef.trace(true);
OSCdef.trace(false);

(

OSCdef(\fromPython, {|msg|
	var cmd;
	//msg.postln;
	cmd = msg[1].asSymbol;
	if(cmd == \volume) {
		var gainval = msg[2].asFloat;
		v.set(\gain, gainval);

	};

	if(cmd == \sim) {
		var sim = msg[2].asSymbol;
		var time = msg[4].asFloat;

		if(sim == \LotkaVolterra) {
			var xv = msg[6].asFloat;
			var yv = msg[8].asFloat;
			//"time: %  x: %  y: %".format(time, xv, yv).postln;
			Ndef(\sonification).set(\tau, time, \xv, xv, \yv, yv);
		};

		if(sim == \KuramotoBasic) {
			var positions, velocities, freqs;
			#positions, i = msg.parseOscArray(5);
			#velocities, i = msg.parseOscArray(i);

			// Map angular velocity to pitch (phase coherence audible as convergence on a single tone)
			freqs = velocities.collect {|val| if(val >= 0) { val.linexp(0.0, 1.0, 1000, 8000) } { (1-val.abs).linexp(0.0, 1.0, 70, 1000) }  };

			// Map angular position to pitch (phase coherence audible as a stable harmonic arrangement)
			//freqs = positions.collect {|val| val=val.sin; if(val >= 0) { val.linexp(0.0, 1.0, 1000, 8000) } { (1.0-val.abs).linexp(0.0, 1.0, 80, 1000) }  };


			//freqs.postln;
			//velocities.postln;
			//positions.postln;
			//"time: %\n  pos: %\n  vel: %".format(time, positions, velocities).postln;
			//"time: %\n  freq: %".format(time, freqs).postln;
			v.set(\freqs, freqs);
		};

	};
}, '/python');


);


(
~testmsg = [ "/python", "sim", "KuramotoBasic", "t", 162.12399291992, "X", "[", 22.179042816162, 21.778385162354, -66.436103820801, 28.633584976196, 21.457347869873, 28.889532089233, 22.029970169067, 22.826515197754, 21.732025146484, -116.21768188477, "]", "dX", "[", 0.27136236429214, 0.38389667868614, -0.73563152551651, 0.23157106339931, 0.49517160654068, 0.17706307768822, 0.30963155627251, 0.13057291507721, 0.39896485209465, -2.1069905757904, "]" ];
#w,l = ~testmsg.parseOscArray(18);
u = w.collect {|val| if(val >= 0) { val.abs.linexp(0.0, 1.0, 1000, 8000) } { val.abs.linexp(0.0, 1.0, 30, 1000) }  };
w;
u;
);



/****
Lotka Volterra
with two populations
****/
(
v = Ndef(\sonification, {
	var tau = \tau.kr(0, 0.1).abs;
	var xv = \xv.kr(0, 0.1).abs;
	var yv = \yv.kr(0, 0.1).abs;
	var gain = \gain.kr(1.0, 2.0).abs;
	var sig, pitches1, pitches2;
	pitches1 = ((Scale.major.ratios2(0, 15, 1) * \c2.f) * (xv + 1));
	pitches2 = ((Scale.minor.ratios2(0, 15, 1) * \gs3.f) * (yv + 1));
	sig = [SinOsc.ar(pitches1).sum * 0.2, LFTri.ar(pitches2).sum * 0.2];
	sig = Limiter.ar(sig);
	sig * gain;
});
);


/****
KuramotoBasic
with 20 oscillators
*****/
(
// Sonification as pitch
v = Ndef(\sonification, {
	var freqs = \freqs.kr(#[100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100], 0.1);
	var amps = \amps.kr(#[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 0.1);
	var phases = \phases.kr(#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], 0.1);
	var gain = \gain.kr(1.0, 2.0).abs;
	var sig = SinOsc.ar(freqs, phases, amps * 0.2);
	sig = Splay.ar(sig);
	sig = Limiter.ar(sig);
	sig * gain;
});

);


Scale.major.ratios2(0, 20, 1);

(
// Metronomes
~metro_pitches = [ 1.0, 1.1224620483089, 1.2599210498937, 1.3348398541685, 1.4983070768743, 1.6817928305039, 1.8877486253586, 1.9999999999945, 2.2449240966115, 2.5198420997804, 2.6696797083296, 2.9966141537402, 3.3635856609985, 3.7754972507067, 3.9999999999778, 4.4898481932105, 5.0396841995469, 5.3393594166444, 5.9932283074638, 6.7271713219784 ];
v = Ndef(\sonification, {
	var freqs = \freqs.kr(#[100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100], 0.05);
	var pitches = ~metro_pitches * \a3.f;
	var amps = \amps.kr(#[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 0.05);
	var phases = \phases.kr(#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], 0.05);
	var gain = \gain.kr(1.0, 2.0).abs;
	var sig = SinOsc.ar(freqs.log10 / 10.0, phases, amps);
	var t_clicks = sig > 0.0;
	sig = SinOsc.ar(pitches, phases, amps) * EnvGen.ar(Env.perc(0.01, 0.2), t_clicks);
	sig = Splay.ar(sig);
	sig = Limiter.ar(sig);
	sig * gain;
});

);



v.set(\freqs, 300!20);

f.unit(\verb, 2, "sonification() lpf(co10000 cv5000) rev(hi0.2)");
v.set(\gain, 0);
v.set(\gain, 1);
