# tcpip-recomp-sound-v1.0

## Sound File Format

- The sound files are written in JSON. The files are translated directly from Staff (Pentagram).
- Each song is a JSON object, which has title, time signature and beat speed as parameters and and notes stored in JSONArray. The notes consist of melody notes and chord notes. As a piece of music is made up of bars, the notes are grouped as bars. Each bar is made up of notes, and for each note inside a bar, it's described as a JSON object with three parameters: the beat to trigger, the tone and the duration.
- For example, for a half-beat C4 note at the 2nd bar's 1st beat, the JSON object of this note should be:

		Song{
			..,
			"beatSpeed":120,
			"chapters": [
				...
				"2": [
					{
					...}
					,
					{
						"toneName": "C4",
						"beat": 1,
						"duration": 0.5
					}
					,
					{
					...}
					],
				"3": [{
				...
			]
		}

## Note Class
The notes as JSON objects are read into Processing program and converted into Note objects.

A Note object has 4 parameters:

- **int** barIndex;
- **float** beatInBar;
- **String** toneName;
- **float** duration; 

## Play a note
With the minim's built-in sinewave sythesized instrument, which takes the start time, duration and frequency as inputs, each note can be played.

## TCP/IP Ping Delays Application Rule

The ping delays to some server, like "baidu.com", are documented in a CSV file, with colomn number equal to the number of notes and row number equal to the cycles to envolve for. Therefore, in every cycle, the notes and delays are matched one by one.

1. If there is a time-out delay in some cycle, the note this delay correlateing to is removed.
2. If the accumulated delay of a note reaches the threshold (0.2ms), this note moves a step (half beat) afterward, and at the same time, all accumulated delays are reset to zero. The delays of each note will be accumulate if there is not any note's accumulated delay reaching the threshold.