+++
title = 'Data'
date = 2024-02-19T23:15:19+05:45
draft = false
+++

The dataset being used for this system consists of MIDI files obtained from various sources, including public MIDI repositories and music composition databases. A lot of MIDI files have been collected, each containing one or multiple instruments. Popular MIDI dataset resources such as the Lakh MIDI Dataset, the MAESTRO Dataset, etc were explored for acquiring a substantial and diverse collection of MIDI files. Lakh MIDI set is the primary source of data. The MIDI files are preprocessed to ensure consistency in terms of resolution, tempo, and key signature.

The Lakh MIDI Dataset(LMD), is a collection of MIDI files that has been used for various music-related research tasks. 
- **Size & Content**: LMD is a collection of over 176,581 unique MIDI files, amounting to nearly 1.7 GB of data when compressed.
- **Origin**: The name "Lakh" comes from the word for 100,000 in Hindi, indicating the initial goal of the dataset's size. The dataset was curated by Colin Raffel as part of his Ph.D. thesis at the University of California, San Diego.
- **Construction**: The MIDI files in the dataset were sourced from the internet and represent a wide variety of genres, artists, and regions. The dataset was constructed using a two-step deduplication process to ensure that there were no significant duplications in the collection.
- **Clean Version**: There's a "clean" subset of the dataset, known as the LMD-clean, which contains 21,425 MIDI files. This subset is particularly useful for researchers as it has been matched directly to entries in the Million Song Dataset, making it easier to pair MIDI data with corresponding audio features and metadata.
- **Applications**: The LMD has been used for various research tasks, including but not limited to:
    - Analyzing the patterns and structures of music across different genres.
    - Training machine learning models for music generation.
    - Studying music theory, chord progressions, and instrument utilization across diverse music pieces.
    
- **Availability**: The dataset is publicly available, allowing researchers and enthusiasts to access and utilize it for various academic, experimental, and creative purposes.

# Use of Dataset

Initially, the MIDI file was parsed and represented as a discrete equally spaced interval. So parsed files had two dimensions: sequence and pitches. Each index of sequence dimension represented a unit of the sixteenth note and each index of pitch dimension indicated the MIDI pitch number of respective notes. This modeled the temporal music data pretty well with a consistent period across sequences. However, due to the resolution to the sixteenth note, a sequence could be populated with a single note or just rests. This led to sparse data which was hard to train the model on. Additionally, each track of MIDI required separate representation adding one more dimension: track. This limited the number of tracks to a predefined value or required merging tracks. Due to the need for chord representation, the notes in pitch dimension couldn't use simple one-hot representation or Embedding Layer. Instead of cross-entropy loss, the sigmoid layer had to be used followed by MSELoss.

Alternatively, on further research, a tokenized format inspired by the Anticipatory Music Transformer paper was explored. In this format, a single MIDI event was represented as a tuple of (offset, duration, pitch, instrument). Arrival Time denotes the arrival time of the MIDI event in the overall MIDI. The offset is calculated as a difference of arrival time between two consecutive MIDI events. Offset is modeled as a category of 100 discretized timesteps. The max value is roughly equivalent to 1 sec, which is a good enough estimate of the difference in succeeding MIDI events. Duration, as the name suggests, is the number of ticks the MIDI event lasts. It is also modeled as a category of 100 discretized timesteps scale by the factor of 10 after the generation. Due to scaling down pre-training and scaling up post-generation, the same number of timesteps as offset translates to the max value of 10 seconds. This scaling is performed to reduce the vocab size, all while maintaining a good enough estimate. A small amount of randomization is allowed to counter the loss of precision. Pitch represents the MIDI pitch constants and Instrument represents the MIDI instruments. Pitch is a category of 128 pitch constants and 1 rest. Instrument is a category of 16 classes of instruments grouping instruments in a single class. Each of these features, except Instrument, has a special token SEPARATOR as a class to model transition between songs. The above-mentioned transformations are applied after the preprocessing is done via techniques of Anticipatory Music Transformer. The result so obtained is of features (arrival time, duration, mark) where the mark is calculated as:

mark = instrument * 128 + pitch

This representation achieves the compact representation of a multi-track MIDI file. An ordinal representation of pitches may be achieved if regression is to be applied. This is mitigated by the use of the mark as classes fed to the embedding layer. Additionally, a single token completely represents one event; be it a rest or a long note. This representation best models the asynchronous nature of music tracks all while maintaining temporal relationship through arrival time and duration. It also removes the need for special representation for chords as they are merely events of several notes.