(* ::Package:: *)

(* :Title: BriscolaMathPackage *)
(* :Context: BriscolaMathPackage` *)
(* :Author: Arto Manuel - Napoli Andrea *)
(* :Summary: Mathematica package for the game of Briscola *)
(* :Copyright:  GS  2024 *)
(* :Package Version: 3 *)
(* :Mathematica Version: 14 *)
(* :History: last modified 31/05/2024 *)
(* :Sources: biblio *)
(* :Limitations:
   this is a preliminary version, for educational purposes only. *)
(* :Discussion:  USES  LINE *)
(* :Requirements: *)
(* :Warning: DOCUMENTATE TUTTO il codice *)


BeginPackage["BriscolaPackage`"]

StartBriscolaGame::usage = "StartBriscolaGame[] starts the briscola game with two players. You'll be first asked to insert the names of the two players. In each game who scores more then 60 points wins. You can play as many games as you want.";

Begin["`Private`"]

GlobalBaseStyle = {FontSize -> 16};
GlobalWindowSize = {250, 70};
GlobalImageSize = {200, 50};
GlobalBaseStyleForButtons = {FontSize -> 15, FontWeight -> "Bold"};

nomeGiocatore1 = "";
nomeGiocatore2 = "";
replay = False;
seed;

(*Replay the last game with the same players*)
replayGame[] :=
  Module[{},
    replay = True;
    CreateDialog[
      {
        TextCell["Inserisci il numero del seed della partita", "Title", GlobalBaseStyle]
        ,
        Column[
          {
            InputField[Dynamic[seed], Number, FieldSize -> {20, 1}, BaseStyle -> {FontSize -> 14}]
            ,
            Button[
              "Conferma"
              ,
              If[seed != "",
                DialogReturn[];
                resetPartita[];
                dialogoNomi[];
              ]
              ,
              BaseStyle -> {FontSize -> 14}
            ]
          }
          ,
          Alignment -> Center
        ]
      }
      ,
      Modal -> True
      ,
      WindowSize -> {300, 130}
    ];
  ];

(*Dialog to ask for player names*)
dialogoNomi[] :=
  Module[{},
    CreateDialog[
      {
        TextCell["Inserisci i nomi dei due giocatori:", "Title", GlobalBaseStyle]
        ,
        Column[
          {
            InputField[Dynamic[nomeGiocatore1], String, FieldSize -> {20, 1}, BaseStyle -> {FontSize -> 14}]
            ,
            InputField[Dynamic[nomeGiocatore2], String, FieldSize -> {20, 1}, BaseStyle -> {FontSize -> 14}]
            ,
            Button[
              "Conferma"
              ,
              If[nomeGiocatore1 != "" && nomeGiocatore2 != "",
                DialogReturn[];
                dialogTurnoGiocatore[RandomInteger[{1, 2}]];
              ]
              ,
              BaseStyle -> {FontSize -> 14}
            ]
          }
          ,
          Alignment -> Center
        ]
      }
      ,
      Modal -> True
    ];
  ];

(*Reset the game state:set the seed,shuffle the cards and draw three cards for each player and the briscola*)
resetPartita[] :=
  Module[{},
    (*Set a new seed if you start a new game again*)
    If[!replay,
      seed = Round[AbsoluteTime[]];
      SetDirectory[NotebookDirectory[]];
    ];
    SeedRandom[seed];
    percorso = "./cards";
    cardCoperta = Import[percorso <> "/retro.jpg"];
    estensione = ".jpg";
    giocatoreA = False;
    giocatoreB = False;
    punteggioA = 0;
    punteggioB = 0;
    cancelA = False;
    cancelB = False;
    cancelCard = True;
    newHandA = False;
    newHandB = False;
    cancelCardA = False;
    cancelCardB = False;
    lastHand = False;
    flag = 0;
    penultimaA = False;
    ultimaA = False;
    penultimaB = False;
    ultimaB = False;
    primoGiocatore = 1;
    cardA = "";
    cardB = "";
   (*variable that contains the new card assigned to the player after the draw*)
    newCardA = "";
    newCardB = "";
    cardGiocataA = "";
    cardGiocataB = "";
    (*complete deck of cards*)
    briscolaCards = {"Asso spade", "2 spade", "3 spade", "4 spade", "5 spade",
       "6 spade", "7 spade", "8 spade", "9 spade", "10 spade", "Asso coppe",
       "2 coppe", "3 coppe", "4 coppe", "5 coppe", "6 coppe", "7 coppe", "8 coppe",
       "9 coppe", "10 coppe", "Asso bastoni", "2 bastoni", "3 bastoni", "4 bastoni",
       "5 bastoni", "6 bastoni", "7 bastoni", "8 bastoni", "9 bastoni", "10 bastoni",
       "Asso denari", "2 denari", "3 denari", "4 denari", "5 denari", "6 denari",
       "7 denari", "8 denari", "9 denari", "10 denari"};
    (*shuffling the deck of cards*)
    briscolaCards = RandomSample[briscolaCards];
    (*arrays containing the hands of players A and B*)
    cardA = extractNCards[3];
    cardB = extractNCards[3];
    briscola = extractNCards[1];
    carteRimanenti = Length[briscolaCards];
    (*horizontal rotation of the briscola card*)
    immagineBriscola = Import[FileNameJoin[{percorso, briscola[[1]] <> estensione}]];
    rotations = {Pi / 2};
    rotatedImages = ImageRotate[immagineBriscola, #]& /@ rotations;
  ];

(*Funzione per pescare una o piu carte carte dal mazzo*)
extractNCards[n_Integer] :=
  Module[{cards},
    cards = Take[briscolaCards, n];
    briscolaCards = Drop[briscolaCards, n];
    cards
  ];

(*Dialog to show who's turn it is*)
dialogTurnoGiocatore[numeroGiocatore_Integer] :=
  CreateDialog[
    {
      Style[
        "Tocca a " <>
          If[numeroGiocatore == 1,
            nomeGiocatore1
            ,
            nomeGiocatore2
          ]
        ,
        GlobalBaseStyle
      ]
    }
    ,
    NotebookEventActions ->
      {
        "WindowClose" :>
            If[numeroGiocatore == 1,
              giocatoreA = True
              ,
              giocatoreB = True
            ]
      }
    ,
    WindowSize -> GlobalImageSize
  ];

(*Dialog to show who won the hand*)
dialogVittoriaGiocatore[numeroGiocatore_Integer] :=
  CreateDialog[
    {
      Style[
        "Mano vinta da " <>
          If[numeroGiocatore == 1,
            nomeGiocatore1
            ,
            nomeGiocatore2
          ] <>
          If[flag != 2,
            "\nTocca a " <>
              If[numeroGiocatore == 1,
                nomeGiocatore1
                ,
                nomeGiocatore2
              ]
            ,
            ""
          ]
        ,
        GlobalBaseStyle
      ]
    }
    ,
    (* This event action is only triggered when the window is closed. It is used to reset some variables before the next hand *)
    NotebookEventActions -> { "WindowClose" :> resetNextHand[numeroGiocatore] }
    ,
    WindowSize -> GlobalWindowSize
  ];

(* This function is used to reset some variables before the next hand *)
resetNextHand[numeroGiocatore_Integer] :=
  Module[{},
    If[numeroGiocatore == 1,
      giocatoreA = True
      ,
      giocatoreB = True
    ];
    cancelCard = False;
    cancelCardA = False;
    cancelCardB = False;
    cancelA = True;
    cancelB = True;
    cardGiocataA = "";
    cardGiocataB = "";
    If[carteRimanenti != 0,
      nuovaMano[numeroGiocatore]
      ,
      If[flag == 0,
        flag += 1
        ,
        If[flag == 2,
          diaologFine[]
          ,
          flag += 1
        ]
      ]
    ]
  ];

(*Dialog to show who won the game*)
diaologFine[] :=
  Module[{},
    If[punteggioA > punteggioB,
      CreateDialog[{Style["PARTITA FINITA!!!\nHA VINTO " <> ToUpperCase[nomeGiocatore1], GlobalBaseStyle]}, WindowSize -> GlobalWindowSize]
      ,
      If[punteggioB > punteggioA,
        CreateDialog[{Style["PARTITA FINITA!!!\nHA VINTO " <> ToUpperCase[nomeGiocatore2], GlobalBaseStyle]}, WindowSize -> GlobalWindowSize]
        ,
        CreateDialog[{Style["PARTITA FINITA!!!\nI due giocatori hanno pareggiato", GlobalBaseStyle]}, WindowSize -> GlobalWindowSize]
      ]
    ];
  ];

(*Add a card to each player's hand*)
nuovaMano[numeroGiocatore_Integer] :=
  Module[{},
    If[carteRimanenti > 1,
      (*the new card is taken from the deck*)
      carteRimanenti -= 2;
      newCardA = extractNCards[1];
      cardA = Append[cardA, newCardA[[1]]];
      newCardB = extractNCards[1];
      cardB = Append[cardB, newCardB[[1]]];
      newHandA = True;
      newHandB = True
      ,
      carteRimanenti -= 1;
      lastHand = True;
      (*if it is player 1's turn, then he is dealt the last card in the deck and player 2 is dealt briscola*)
      If[numeroGiocatore == 1, 
        newCardA = extractNCards[1];
        cardA = Append[cardA, newCardA[[1]]];
        newHandA = True;
        newCardB = briscola;
        cardB = Append[cardB, briscola[[1]]];
        newHandB = True
        ,
        (*if it is player 2's turn, then he is dealt the last card in the deck and player 1 is dealt briscola*)
        newCardB = extractNCards[1];
        cardB = Append[cardB, newCardB[[1]]];
        newHandB = True;
        newCardA = briscola;
        cardA = Append[cardA, briscola[[1]]];
        newHandA = True
      ]
    ]
  ];

(*Evaluate who won the hand and assign points*)
evaluatePlayedHand[] :=
  Module[{},
    If[cardGiocataA != "" && cardGiocataB != "",
      If[manoVincente[cardGiocataA, cardGiocataB] == 1,
        dialogVittoriaGiocatore[1]
        ,
        dialogVittoriaGiocatore[2]
      ]
      ,
      If[cardGiocataA != "",
        primoGiocatore = 1;
        dialogTurnoGiocatore[2]
        ,
        primoGiocatore = 2;
        dialogTurnoGiocatore[1]
      ]
    ]
  ];

(*Funzione per calcolare il vincitore e il punteggio*)
manoVincente[cardGiocataA_, cardGiocataB_] :=
  Module[{valori, punti, seme1, seme2, valore1, valore2},
    valori = <|"Asso" -> 11, "3" -> 10, "10" -> 4, "9" -> 3, "8" -> 2, "7" -> 7, "6" -> 6, "5" -> 5, "4" -> 4, "2" -> 2|>;
    punti = <|"Asso" -> 11, "3" -> 10, "10" -> 4, "9" -> 3, "8" -> 2, "7" -> 0, "6" -> 0, "5" -> 0, "4" -> 0, "2" -> 0|>;
    briscol = Last @ StringSplit[briscola[[1]]];

    (*the suits and values of the cards played by the two players are taken*)
    seme1 = Last @ StringSplit[cardGiocataA];
    seme2 = Last @ StringSplit[cardGiocataB];
    valore1 = First @ StringSplit[cardGiocataA];
    valore2 = First @ StringSplit[cardGiocataB];

    (*Casi in cui uno dei due giocatori ha giocato briscola*)
    If[seme1 == briscol && seme2 != briscol,
      punteggioA = punteggioA + punti[valore1] + punti[valore2];
      Return[1]
    ];
    If[seme2 == briscol && seme1 != briscol,
      punteggioB = punteggioB + punti[valore1] + punti[valore2];
      Return[2]
    ];
    
    (*The two players play the same suit => the higher value wins*)
    If[seme1 == seme2 && punti[valore1] > punti[valore2],
        punteggioA = punteggioA + punti[valore1] + punti[valore2];
        Return[1]
    ];
    If[seme1 == seme2 && punti[valore1] < punti[valore2],
        punteggioB = punteggioB + punti[valore1] + punti[valore2];
        Return[2]
    ];
    
    (*The two players play different seeds but different trumps => the first one to have played wins*)
    If[primoGiocatore == 1,
      punteggioA = punteggioA + punti[valore1] + punti[valore2];
      Return[1]
      ,
      punteggioB = punteggioB + punti[valore1] + punti[valore2];
      Return[2]
    ];
  ];

(*Function to start a new game.Shuffle the deck and ask for players' names.*)
startGame[] :=
  Module[{},
    resetPartita[];
    dialogoNomi[];
  ];

(* Starts the briscola game with two players. You'll be first asked to insert the names of the two players. In each game who scores more then 60 points wins *)
StartBriscolaGame[] :=
  Module[{},
    startGame[];
    Print @
      Row[
        {
          Column[
            {
              (*HAND PLAYER 1*)
              DynamicModule[
                {testo = ""}
                ,
                Row[
                  {
                    (* first card view and action when pressed *)
                    Dynamic @
                      If[!ultimaA,
                        Button[
                          Dynamic @
                            If[giocatoreA,
                              Import[FileNameJoin[{percorso, cardA[[1]] <> estensione}]]
                              ,
                              cardCoperta
                            ]
                          ,
                          If[giocatoreA,
                            giocatoreA = False; 
                            (*saves the value of the played card so it can be shown on the playing field *)
                            testo = cardA[[1]];
                            cardGiocataA = cardA[[1]]; 
                            (*the played card is removed from the array containing the player's hand *)
                            cardA = DeleteCases[cardA, cardA[[1]]];
                            (*Card rotation so that the played card is on the outside *)
                            cardA = RotateLeft[cardA];
                            cancelA = True;
                            evaluatePlayedHand[];
                            newHandA = False;
                            cancelCardA = True;
                            (*if flag is 1 is the penultimate hand was made so the second card is not shown*)
                            If[flag == 1,
                              penultimaA = True
                              ,
                              (*if flag is 2 is the last hand was made so cards are \ no longer shown*)
                              If[flag == 2, ultimaA = True]
                            ]
                          ]
                          ,
                          Enabled -> Dynamic[giocatoreA]
                        ]
                        ,
                        ""
                      ]
                    ,
                    (* second card view and action when pressed *)
                    Dynamic @
                      If[!penultimaA,
                        Button[
                          Dynamic @
                            If[giocatoreA,
                              Import[FileNameJoin[{percorso, cardA[[2]] <> estensione}]]
                              ,
                              cardCoperta
                            ]
                          ,
                          If[giocatoreA,
                            giocatoreA = False;
                            testo = cardA[[2]];
                            cardGiocataA = cardA[[2]];
                            cardA = DeleteCases[cardA, cardA[[2]]];
                            cardA = RotateRight[cardA];
                            cancelA = True;
                            evaluatePlayedHand[];
                            newHandA = False;
                            cancelCardA = True;
                            If[flag == 1, penultimaA = True];
                          ]
                          ,
                          Enabled -> Dynamic[giocatoreA]
                        ]
                        ,
                        ""
                      ]
                    ,
                    (* third card view and action when pressed *)
                    Dynamic @
                      If[!cancelA,
                        Button[
                          Dynamic @
                            If[giocatoreA,
                              Import[FileNameJoin[{percorso, cardA[[3]] <> estensione}]]
                              ,
                              cardCoperta
                            ]
                          ,
                          If[giocatoreA,
                            giocatoreA = False;
                            testo = cardA[[3]];
                            cardGiocataA = cardA[[3]];
                            cardA = DeleteCases[cardA, cardA[[3]]];
                            cancelA = True;
                            evaluatePlayedHand[];
                          ]
                          ,
                          Enabled -> Dynamic[giocatoreA]
                        ]
                        ,
                        Dynamic @
                          If[newHandA,
                            Button[
                              Dynamic @
                                If[giocatoreA,
                                  Import[FileNameJoin[{percorso, newCardA[[1]] <> estensione}]]
                                  ,
                                  cardCoperta
                                ]
                              ,
                              If[giocatoreA,
                                giocatoreA = False;
                                testo = newCardA[[1]];
                                cardGiocataA = newCardA[[1]];
                                cardA = DeleteCases[cardA, newCardA[[1]]];
                                cancelA = True;
                                cancelCardA = True;
                                evaluatePlayedHand[];
                                newHandA = False;
                              ]
                              ,
                              Enabled -> Dynamic[giocatoreA]
                            ]
                            ,
                            ""
                          ]
                        ,
                        ""
                      ]
                    ,
                    Spacer[200]
                    ,
                    Pane[
                      Dynamic @
                        If[(cancelA && cancelCard) || cancelCardA,
                          Button[Import[FileNameJoin[{percorso, testo <> estensione}]], Enabled -> False, ImageSize -> {150, 150}]
                          ,
                          ""
                        ]
                    ]
                  }
                ]
              ], 
              (*DECK AND ROTATED BRISCOLA*)
              Row[
                {
                  Button[Overlay[{cardCoperta, Style[Dynamic[carteRimanenti], White, Bold, FontSize -> 35]}, Alignment -> Center], Enabled -> False]
                  ,
                  Dynamic @
                    If[lastHand,
                      ""
                      ,
                      Button[ImageAssemble[Partition[rotatedImages, 1]], Enabled -> False]
                    ]
                }
              ],
              (*HAND PLAYER 2*)
              DynamicModule[
                {testo = ""}
                ,
                Row[
                  {
                    (* first card view and action when pressed *)
                    Dynamic @
                      If[!ultimaB,
                        Button[
                          Dynamic @
                            If[giocatoreB,
                              Import[FileNameJoin[{percorso, cardB[[1]] <> estensione}]]
                              ,
                              cardCoperta
                            ]
                          ,
                          If[giocatoreB,
                            giocatoreB = False;
                            testo = cardB[[1]];
                            cardGiocataB = cardB[[1]];
                            cardB = DeleteCases[cardB, cardB[[1]]];
                            cardB = RotateLeft[cardB];
                            cancelB = True;
                            evaluatePlayedHand[];
                            newHandB = False;
                            cancelCardB = True;
                            If[flag == 1,
                              penultimaB = True
                              ,
                              If[flag == 2, ultimaB = True]
                            ];
                          ]
                          ,
                          Enabled -> Dynamic[giocatoreB]
                        ]
                        ,
                        ""
                      ]
                    ,
                    (* second card view and action when pressed *)
                    Dynamic @
                      If[!penultimaB,
                        Button[
                          Dynamic @
                            If[giocatoreB,
                              Import[FileNameJoin[{percorso, cardB[[2]] <> estensione}]]
                              ,
                              cardCoperta
                            ]
                          ,
                          If[giocatoreB,
                            giocatoreB = False;
                            testo = cardB[[2]];
                            cardGiocataB = cardB[[2]];
                            cardB = DeleteCases[cardB, cardB[[2]]];
                            cardB = RotateRight[cardB];
                            cancelB = True;
                            evaluatePlayedHand[];
                            newHandB = False;
                            cancelCardB = True;
                            If[flag == 1, penultimaB = True];
                          ]
                          ,
                          Enabled -> Dynamic[giocatoreB]
                        ]
                        ,
                        ""
                      ]
                    ,
                    (* third card view and action when pressed *)
                    Dynamic @
                      If[!cancelB,
                        Button[
                          Dynamic @
                            If[giocatoreB,
                              Import[FileNameJoin[{percorso, cardB[[3]] <> estensione}]]
                              ,
                              cardCoperta
                            ]
                          ,
                          If[giocatoreB,
                            giocatoreB = False;
                            testo = cardB[[3]];
                            cardGiocataB = cardB[[3]];
                            cardB = DeleteCases[cardB, cardB[[3]]];
                            cancelB = True;
                            evaluatePlayedHand[];
                          ]
                          ,
                          Enabled -> Dynamic[giocatoreB]
                        ]
                        ,
                        Dynamic @
                          If[newHandB,
                            Button[
                              Dynamic @
                                If[giocatoreB,
                                  Import[FileNameJoin[{percorso, newCardB[[1]] <> estensione}]]
                                  ,
                                  cardCoperta
                                ]
                              ,
                              If[giocatoreB,
                                giocatoreB = False;
                                testo = newCardB[[1]];
                                cardGiocataB = newCardB[[1]];
                                cardB = DeleteCases[cardB, newCardB[[1]]];
                                cancelB = True;
                                cancelCardB = True;
                                evaluatePlayedHand[];
                                newHandB = False;
                              ]
                              ,
                              Enabled -> Dynamic[giocatoreB]
                            ]
                            ,
                            ""
                          ]
                        ,
                        ""
                      ]
                    ,
                    Spacer[200]
                    ,
                    Pane[
                      Dynamic @
                        If[(cancelB && cancelCard) || cancelCardB,
                          Button[Import[FileNameJoin[{percorso, testo <> estensione}]], Enabled -> False, ImageSize -> {150, 150}]
                          ,
                          ""
                        ]
                    ]
                  }
                ]
              ]
            }
          ]
          ,
          Spacer[10]
          ,
          Column[
            {
              (*TABLE OF NAMES AND SCORES*)
              Row[
                {
                  Spacer[250], 
                  Button[
                    Graphics[{Red, Line[{{0.35, 0.35}, {0.65, 0.65}}], Line[{{0.35, 0.65}, {0.65, 0.35}}]}, AspectRatio -> 1], 
                    NotebookDelete[EvaluationCell[]], 
                    ImageSize -> {25, 25}
                  ]
                }, 
                Alignment -> Right
              ], 
              Grid[
                {
                  {Style[Dynamic[nomeGiocatore1], Bold], Style[Dynamic[nomeGiocatore2], Bold]}, 
                  {Dynamic[punteggioA], Dynamic[punteggioB]}
                }, 
                Frame -> All, 
                Alignment -> {Center, Center},  
                ItemSize -> {{Scaled[0.1], Scaled[0.1]}}
              ], 
              Graphics[
                {
                  Text[
                    Dynamic @ Style["seed: " <> ToString[seed], Bold, FontSize -> 15]
                  ]
                }, 
                ImageSize -> {160,40}
              ], 
              Button["Ricomincia partita", startGame[], ImageSize -> GlobalImageSize, BaseStyle -> GlobalBaseStyleForButtons], 
              Button["Ripeti partita", replayGame[], ImageSize -> GlobalImageSize, BaseStyle -> GlobalBaseStyleForButtons]
            }
          ]
        }
      ];
  ];

End[]

EndPackage[]
