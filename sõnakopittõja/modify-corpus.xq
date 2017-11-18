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



(: Lemmatize negation tokens :) 
for $neg in db:open('sonakopittoja')//w[
              matches(., "^(" || string-join(
                ("en","ed","eb","emme","eväd","ette"), "|") || ")$")
            ]
  return (
    insert node attribute {"pos"} {"V"} into $neg,
    insert node attribute {"lemma"} {"eb"} into $neg,
    insert node attribute {"analysis"} {
      switch ($neg/text())
      case ("en") return "Pers Prs Ind Sg1 Neg"
      case ("ed") return "Pers Prs Ind Sg2 Neg"
      case ("eb") return "Pers Prs Ind Sg3 Neg"
      case ("emme") return "Pers Prs Ind Pl1 Neg"
      case ("ette") return "Pers Prs Ind Pl2 Neg"
      case ("eväd") return "Pers Prs Ind Pl3 Neg"
      default return ()
    } into $neg
  )




(: Lemmatize õlla tokens :) (:
for $õlla in db:open('sonakopittoja')//w[
              matches(., "^(" || string-join(
                ("õõn","õõt","on","õõmmõ","õõttõ","õlla"), "|") || ")$")
            ]
  return (
    insert node attribute {"pos"} {"V"} into $õlla,
    insert node attribute {"lemma"} {"õlla"} into $õlla,
    insert node attribute {"analysis"} {
      switch ($õlla/text())
      case ("õõn") return "Pers Prs Ind Sg1 Aff"
      case ("õõt") return "Pers Prs Ind Sg2 Aff"
      case ("on") return "Pers Prs Ind Sg3 Aff"
      case ("õõmmõ") return "Pers Prs Ind Pl1 Aff"
      case ("õõttõ") return "Pers Prs Ind Pl2 Aff"
      case ("õlla") return "Pers Prs Ind Pl3 Aff"
      default return ()
    } into $õlla
  )
:)



(: Export to Korp with Giellatekno tags :) (:
declare function local:export-to-giellatekno-vrt($nodes as node()*)
{
  for $node in $nodes
  return
    typeswitch ($node)
    
    case (element(w)) return
      concat(
        (: 1) token :)
        $node/text(),
        (: 2) lemma+morphemes :)
        if (exists($node/@lemma)) then (out:tab() || $node/@lemma) else (),
        out:nl()
      )
      
    case (element(*)) return
      (
        element {name($node)} {(
          $node/@*, (: pass through all attributes :)
          out:nl(), (: add a newline :)
          for $child in $node/node()
            return local:export-to-giellatekno-vrt($child)
        )},
      out:nl()
    )
    
    default return
      ()
};
:)
(:
declare option output:method "xml";
declare option output:indent "no";
declare option output:omit-xml-declaration "yes";
local:export-to-giellatekno-vrt(db:open('sonakopittoja')/corpus) :)