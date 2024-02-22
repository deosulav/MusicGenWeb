+++
title = 'Model'
date = 2024-02-19T23:15:29+05:45
draft = false
+++

LSTM is ideal for music generation because it models the sequence generation problem. There are 4 features: offset, duration, pitch, and instrument. Each of these features is modeled separately and combined later. For single-feature modeling, the following layers are used.


- **Embedding Layer**: An embedding layer is used to convert the feature into embeddings. This allows for better categorical representation in the form of a fixed-sized vector of floating point numbers. The Embedding layer in PyTorch is a learnable lookup table. At its core, it's essentially a matrix where each row is a vector representation of an item in the discrete data (e.g., a word in the vocabulary). When this table is queried with an integer index (or indices), it returns the vector (or vectors) at those positions. This is usually a better representation than one-hot encoding and more efficient than one-hot encoding followed by a dense layer. The input to this layer is of shape (Batch Size, Sequence Length, Vocab Size). Vocab Size is specific to the feature used, i.e. it is different for offset, duration, pitch, and instrument. Vocab Size is now represented by a fixed-size vector of size Embedding Size.
- **Squeeze Layer**: The output returned from the Embedding Layer is of shape (Batch Size, Sequence Length, 1, Embedding Size). This is not suitable to feed in the LSTM Layer as it requires 3-D tensors for batched input. This layer squeezes the dimension back to (Batch Size, Sequence Length, Embedding Size).
- **Encoding LSTM**: In this stage, four LSTMs are used as an encoder of sorts to capture the musical information of the datasets. This was in done hopes of distilling the sequential musical information in an encoding. Each of the four LSTMs attended to a specific musical information namely offset, duration, pitch, and instrument.
- **Large LSTM**: Previously each aspect of a music was attended to by a separate LSTM. But in music, it is possible for different features to affect each other. So the four information are fed into a singular LSTM to model the interdependencies of the four musical parameters.
- **Classification Linear Layers**: Finally we have some scaffolding layers to allow our information to be in a format where classification is possible. Notes and instruments are classified as one's intuition would suggest. But offsets and durations are also predicted by classification, as opposed to regression which was suggested by common wisdom. We chose to work with this deviation because the offsets and duration in MIDI are largely discrete, and regression was not able to predict them as such. We also tried to use PoissionNLLLoss which was hailed to train a network such that it predicts positive integers, which would have been ideal for us. However, we were not able to see this claim validated.  


![Model](./model.png)