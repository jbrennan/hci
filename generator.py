from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import re
import random
import hashlib
from nltk.corpus import wordnet as wn

class TreeNode():
    def __init__(self, value, parent=None):
        self.value = value
        self.parent = parent
        self.children = []


def readtree():
    root = node = TreeNode(None)
    depth = -1
    pattern = re.compile(r'^( *)(.*)')
    lineno = 0
    with open('sentence.frames', 'r') as f:
        for l in f:
            match = pattern.match(l)

            # Ignore comments and blank lines
            if not match.group(2) or match.group(2).startswith('#'):
                continue

            newdepth = len(match.group(1)) / 4
            if not newdepth == int(newdepth):
                raise ValueError(" Indentation not a multiple of 4")
            if newdepth > depth + 1:
                raise ValueError("Indentation jump too big")
            while newdepth <= depth:
                node = node.parent
                depth -= 1

            newnode = TreeNode(match.group(2), node)
            node.children.append(newnode)
            node = newnode
            depth += 1
    return root

def generatephrase(tree):
    path = []
    while True:
        chunk = Chunk(tree.value)
        chunk.pickword()
        path.append(chunk)
        if chunk.continued != bool(tree.children):
            raise ValueError("continuation format")
        if tree.children:
            tree = pickchild(chunk.word, tree.children)
        else:
            return path

def pickchild(word, children):
    # This is not good at all, but it'll do for the prototype...
    choice = ord(hashlib.md5(word).digest()[0]) % len(children)
    return children[choice]


class Chunk():
    pattern = re.compile(r'^(.*)\[(.*)\](.*)( ->|\.)$')

    def __init__(self, descriptor):
        match = self.pattern.match(descriptor)
        self.pre = match.group(1)
        if descriptor in ('adverb', 'adjective') or descriptor.endswith('verb'):
            self.descriptor = descriptor
        else:
            self.descriptor = match.group(2) + '.n.01'
        self.post = match.group(3)
        self.continued = (match.group(4) == ' ->')
        self.clue = match.group(2) #wn.synset(self.descriptor).lemmas[0].name
        self.word = None

    def __repr__(self):
        return '<Chunk {0}[{1}={2}]{3}>'.format(self.pre, self.descriptor,
        self.word, self.post)

    def pickword(self):
        try:
            self.word = random.choice(list(passablewords(self.descriptor)))
        except: pass

def passablewords(descriptor):
    if descriptor == 'adverb': return adverbs()
    if descriptor == 'adjective': return adjectives()
    if descriptor.endswith('verb'): return verbs(descriptor)
    synset = wn.synset(descriptor)
    return lemma_names(hyponyms_trans(synset))

def lemma_names(synsets):
    for s in synsets:
        for l in s.lemmas:
            yield l.name

def hyponyms_trans(root_synset):
    return root_synset.closure(lambda s: s.hyponyms())

def verbs(descriptor):
    return wn.all_lemma_names('v')

def adverbs():
    return wn.all_lemma_names('r')
def adjectives():
    return wn.all_lemma_names('a')

if __name__ == '__main__':
    tree = readtree().children[0]
    print(generatephrase(tree))

