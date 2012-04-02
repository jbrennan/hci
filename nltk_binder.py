import nltk

wn = nltk.corpus.wordnet

def wn_noun_iter():
	for synset in list(wn.all_synsets('n'))[:10000]:
		yield synset