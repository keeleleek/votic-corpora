(: doc('/home/kristian/Projektid/Vadja/korpus/sõnakopittõja.xml') :)



(: Some useful output declarations  :)(:
declare option output:method "xml";
declare option output:indent "no";
declare option output:omit-xml-declaration "yes";
:)



(: Normalize space in all text nodes :)(:
for $text-with-nl in db:open("sonakopittoja")//text()[matches(.,"\n")]
  return replace node $text-with-nl with normalize-space($text-with-nl)
:)



(: Normalize unicode in all text nodes :)(:
for $text in db:open("sonakopittoja")//text()
  return replace node $text with normalize-unicode($text)
:)



(: Insert title attribute of the corpus document element :)
(:insert node attribute {"title"} {"Vad̕d̕a sõnakopittõja"} into db:open('sonakopittoja')/corpus:)



(: Tokenize sentence elements (e.g populate <s> with <w>) :) (:
for $s in db:open('sonakopittoja')//*[exists(./text())]
  return
      replace node $s 
      with (
        <s>{
          for $non-empty-token in analyze-string($s, '(\.\.\.)|[\W]')//text()[not(.=" ")]
            return <w>{$non-empty-token}</w>
        }</s>
      )
:)



(: Change č graphemes  :)(:
for $text-with-tš in db:open('sonakopittoja')//(text()|@*)[matches(.,"tš","i")]
  let $text-with-č :=
              if(contains($text-with-tš, "ttš"))
              then(replace($text-with-tš, "ttš", "čč"))
              else(if(contains($text-with-tš, "tš"))
              then(replace($text-with-tš, "tš", "č"))
              else(replace($text-with-tš, "Tš", "Č")))
  return
    replace value of node $text-with-tš
    with $text-with-č
:)



(: Lemmatize negation tokens :) (:
for $neg in db:open('sonakopittoja')//w[
              matches(., "^(" || string-join(
                ("en","ed","eb","emme","eväd","ette"), "|") || ")$")
            ]
  return
    insert node attribute {"lemma"} {"neg"} into $neg
:)



(: Lemmatize õlla tokens :) (:
for $õlla in db:open('sonakopittoja')//w[
              matches(., "^(" || string-join(
                ("õõn","õõt","on","õõmmõ","õõttõ","õlla",
                 "õlko","õõtko"), "|") || ")$")
            ]
  return
    insert node attribute {"lemma"} {"õlla"} into $õlla
:)