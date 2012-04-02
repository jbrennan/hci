import nltk

wn = nltk.corpus.wordnet

# see: http://nltk.googlecode.com/svn/trunk/doc/howto/wordnet.html

def wn_noun_iter():
	for synset in list(wn.all_synsets('n'))[:25000]:
		yield synset


def wn_verb_iter():
	for synset in list(wn.all_synsets('v'))[:25000]:
		yield synset