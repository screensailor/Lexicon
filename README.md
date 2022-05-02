# Lexicon
_A specification for shared indefinitely evolving namespaces, ontologies and languages that nurture diversity of dialects by enticing contributions from the native speakers of each domain of expertise in an organisation._

Lexicon is intended to serve as a foundation for ontology led development, semantic reactive programming and [software gardening](https://github.com/thousandyears/garden).

While we are working towards a fully featured 1.0 complete with respectable documentation, please consider visiting [mindflare.app](https://mindflare.app) for a quick demo of the basic concepts.

## To Do
### Specification
- Formal grammar specification
- SKOS (or other standard) serialisation
- CRDT Lexicon
- Composable lexicons
	- @ https://some.remote.lexicon
	- @ local.lexicon
- Default values 
	- Literals 
	- By reference 
- Notes/comments
- Own children override inherited children?
	- Overrides instead of /in addition to synonyms?
- Paste
	- Multiple roots (leading up to composable lexicons)
	- Branches as self-sufficient lexicons

### Implementation
- Search
	- Time limited to allow results to include inherited nodes (breadth first traversal, of course)
	- All inheritors of this lemma
	- All synonyms
	- More complex conditions
