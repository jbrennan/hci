from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import re
import random
import hashlib
import json
from nltk.corpus import wordnet as wn

names = []
with open('names.list', 'r') as f:
    for l in f:
        names.append(l.strip())

spellcheck = set()
with open('spellcheck.20') as f:
    for l in f:
        spellcheck.add(l.strip())

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
    # Return a list of Chunks following the sentence frame in tree.
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
    # Pick a child branch of the tree based on the previous word. Must be
    # deterministic; should not be biased to any answer.
    # This is not good at all, but it'll do for the prototype...
    # For the first word, there's only one child.
    if word == None: return children[0]
    choice = ord(hashlib.md5(word).digest()[0]) % len(children)
    return children[choice]


class Chunk():
    pattern = re.compile(r'^(.*)\[(.*)\](.*)( ->|\.)$')

    def __init__(self, descriptor):
        match = self.pattern.match(descriptor)
        if match is None: raise ValueError(descriptor)
        self.pre = match.group(1)
        self.descriptor = match.group(2)
        self.post = match.group(3)
        self.continued = (match.group(4) == ' ->')
        self.pickclue()
        self.word = None

    def __repr__(self):
        return '<Chunk {0}[{1}={2}]{3}>'.format(self.pre, self.descriptor,
        self.word, self.post)

    def pickclue(self):
        #wn.synset(self.descriptor).lemmas[0].name
        if '=' in self.descriptor:
            self.clue = self.descriptor.partition('=')[2]
        elif '.n.' in self.descriptor:
            self.clue = canonical_form(self.descriptor.partition('.n.')[0])
        else:
            self.clue = ' '.join([x for x in self.descriptor.split(' ')
                if not x.startswith('*')])

    def pickword(self):
        self.word = canonical_form(
                random.choice(list(passablewords(self.descriptor))))

    def to_json(self):
        return json.dumps({
            'pre': self.pre,
            'clue': self.clue,
            'word': self.word,
            'post': self.post,
            'last': not self.continued
        })

def passablewords(descriptor):
    if descriptor == 'adverb': return adverbs()
    if descriptor == 'adjective': return adjectives()
    if descriptor.endswith('verb'): return verbs(descriptor)
    if descriptor == 'name': return names
    # else it's a noun
    lookup = descriptor.partition('=')[0]
    try:
        synset = wn.synset(lookup)
    except:
        print(lookup)
        raise
    return lemma_names(hyponyms_trans(synset))

def canonical_form(word):
    # Return the form of a word for display to the user
    return word.replace('_', ' ');

def lemma_names(synsets):
    for s in synsets:
        for l in s.lemmas:
            if l.name in spellcheck:
                yield l.name

def hyponyms_trans(root_synset):
    return root_synset.closure(lambda s: s.hyponyms())

def verbs(descriptor):
    return spellcheck.intersection(wn.all_lemma_names('v'))
def adverbs():
    return spellcheck.intersection(wn.all_lemma_names('r'))
def adjectives():
    return spellcheck.intersection(wn.all_lemma_names('a'))

# Counting the number of possible passwords

def passwordcount():
    tree = readtree()
    for t in tree.children:
        c = count(t)
        print(sum(c) / len(c))

def count(tree):
    chunk = Chunk(tree.value)

    if tree.children:
        tree.value = (len(list(passablewords(chunk.descriptor))) /
                len(tree.children))
        if tree.value == 0:
            raise Exception(chunk.descriptor)
        rv = []
        for c in tree.children:
            rv.extend(count(c))
        return rv
    else:
        tree.value = len(list(passablewords(chunk.descriptor)))
        if tree.value == 0:
            raise Exception(chunk.descriptor)

        total = tree.value
        node = tree.parent
        while True:
            total *= node.value
            node = node.parent
            if node.parent is None: break
        return [total]

# INTERFACE FOR RUBY

def startup():
    # Generate and discard a passphrase to load NLTK
    tree = readtree().children[0]
    generatephrase(tree)

def generate(which_tree):
    # Return a list of Chunks
    tree = readtree().children[which_tree]
    return generatephrase(tree)

def nextbranch(which_tree, words):
    tree = readtree().children[which_tree]
    for w in words:
        tree = pickchild(w, tree.children)
    return Chunk(tree.value)

if __name__ == '__main__':
    #import pdb; pdb.set_trace()
    print(generate(0))
    passwordcount()

