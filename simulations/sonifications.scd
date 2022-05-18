
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
			//freqs = velocities * 5000.0;
			freqs = velocities.collect {|val| if(val >= 0) { val.abs.linexp(0.0, 1.0, 2000, 8000) } { val.abs.linexp(0.0, 1.0, 70, 2000) }  };
			freqs.postln;
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


( // Lotka Volterra
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

( // KuramotoBasic with 10 oscillators
~freqs = 100!20;
~amps = 1.0!20;
~phases = 0.0!20;
v = Ndef(\sonification, {
	var freqs = \freqs.kr(#[100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100], 0.05);
	var amps = \amps.kr(#[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 0.05);
	var phases = \phases.kr(#[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], 0.05);
	var gain = \gain.kr(1.0, 2.0).abs;
	var sig = SinOsc.ar(freqs, phases, amps);
	sig = Splay.ar(sig);
	sig = Limiter.ar(sig);
	sig * gain;
});
);

v.set(\freqs, 200!20);

f.unit(\verb, 2, "sonification() lpf(co10000 cv5000) rev()");
v.set(\gain, 0);
v.set(\gain, 1);
