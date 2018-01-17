#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supportting the PID methodology              #
#       Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique     #
#       et de Microelectronique de Montpellier). All Right reserved.                    #
#                                                                                       #
#       This software is free software: you can redistribute it and/or modify           #
#       it under the terms of the CeCILL-C license as published by                      #
#       the CEA CNRS INRIA, either version 1                                            #
#       of the License, or (at your option) any later version.                          #
#       This software is distributed in the hope that it will be useful,                #
#       but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                    #
#       CeCILL-C License for more details.                                              #
#                                                                                       #
#       You can find the complete license description on the official website           #
#       of the CeCILL licenses family (http://www.cecill.info/index.en.html)            #
#########################################################################################

##################################################################
########### CMake License file description : CeCILL-B V1 #########
##################################################################

set(	LICENSE_NAME 			"CeCILL-B")
set(	LICENSE_VERSION			"1")
set(	LICENSE_FULLNAME 		"Contrat de license de logiciel libre CeCILL-B")
set(	LICENSE_AUTHORS 		"the CEA CNRS INRIA")
set(	LICENSE_IS_OPEN_SOURCE 		TRUE)

set(	LICENSE_HEADER_FILE_DESCRIPTION
"/*      File: @PROJECT_FILENAME@
*       This file is part of the program ${${PROJECT_NAME}_FOR_LICENSE}
*       Program description : ${${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE}
*       Copyright (C) ${${PROJECT_NAME}_YEARS_FOR_LICENSE} - ${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE}. All Right reserved.
*
*       This software is free software: you can redistribute it and/or modify
*       it under the terms of the ${LICENSE_NAME} license as published by
*       ${LICENSE_AUTHORS}, either version ${LICENSE_VERSION}
*       of the License, or (at your option) any later version.
*       This software is distributed in the hope that it will be useful,
*       but WITHOUT ANY WARRANTY; without even the implied warranty of
*       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
*       ${LICENSE_NAME} License for more details.
*
*       You should have received a copy of the ${LICENSE_NAME} License
*       along with this software. If not, it can be found on the official website
*       of the CeCILL licenses family (http://www.cecill.info/index.en.html).
*/
")


set(	LICENSE_LEGAL_TERMS
"
Software license for the software named : ${${PROJECT_NAME}_FOR_LICENSE}

Software description : ${${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE}

Copyright (C) ${${PROJECT_NAME}_YEARS_FOR_LICENSE} ${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE}

This software is free software: you can redistribute it and/or modify it under the terms of the ${LICENSE_NAME} license as published by
 ${LICENSE_AUTHORS}, either version ${LICENSE_VERSION} of the License, or (at your option) any later version. This software
is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Information about license applying to this software:

License : ${LICENSE_NAME}

Official name of the license : ${LICENSE_FULLNAME}

Version of the license : ${LICENSE_VERSION}

License authors : ${LICENSE_AUTHORS}

Additionnal information can be found on the official website of the CeCILL licenses family (http://www.cecill.info/index.en.html)

Legal terms of the license are reproduced below (french and english versions are provided):

----------------------- French Version ---------------------------

CONTRAT DE LICENCE DE LOGICIEL LIBRE CeCILL-B

Version 1.0 du 2006-09-05.

Avertissement

Ce contrat est une licence de logiciel libre issue d'une concertation entre ses auteurs afin que le respect de deux grands principes préside à sa rédaction:

d'une part, le respect des principes de diffusion des logiciels libres: accès au code source, droits étendus conférés aux utilisateurs,
d'autre part, la désignation d'un droit applicable, le droit français, auquel elle est conforme, tant au regard du droit de la responsabilité civile que du droit de la propriété intellectuelle et de la protection qu'il offre aux auteurs et titulaires des droits patrimoniaux sur un logiciel.
Les auteurs de la licence CeCILL-B1 sont:

Commissariat à l'Energie Atomique - CEA, établissement public de recherche à caractère scientifique, technique et industriel, dont le siège est situé 25 rue Leblanc, immeuble Le Ponant D, 75015 Paris.

Centre National de la Recherche Scientifique - CNRS, établissement public à caractère scientifique et technologique, dont le siège est situé 3 rue Michel-Ange, 75794 Paris cedex 16.

Institut National de Recherche en Informatique et en Automatique - INRIA, établissement public à caractère scientifique et technologique, dont le siège est situé Domaine de Voluceau, Rocquencourt, BP 105, 78153 Le Chesnay cedex.

Préambule

Ce contrat est une licence de logiciel libre dont l'objectif est de conférer aux utilisateurs une très large liberté de modification et de redistribution du logiciel régi par cette licence.

L'exercice de cette liberté est assorti d'une obligation forte de citation à la charge de ceux qui distribueraient un logiciel incorporant un logiciel régi par la présente licence afin d'assurer que les contributions de tous soient correctement identifiées et reconnues.

L'accessibilité au code source et les droits de copie, de modification et de redistribution qui découlent de ce contrat ont pour contrepartie de n'offrir aux utilisateurs qu'une garantie limitée et de ne faire peser sur l'auteur du logiciel, le titulaire des droits patrimoniaux et les concédants successifs qu'une responsabilité restreinte.

A cet égard l'attention de l'utilisateur est attirée sur les risques associés au chargement, à l'utilisation, à la modification et/ou au développement et à la reproduction du logiciel par l'utilisateur étant donné sa spécificité de logiciel libre, qui peut le rendre complexe à manipuler et qui le réserve donc à des développeurs ou des professionnels avertis possédant des connaissances informatiques approfondies. Les utilisateurs sont donc invités à charger et tester l'adéquation du logiciel à leurs besoins dans des conditions permettant d'assurer la sécurité de leurs systèmes et/ou de leurs données et, plus généralement, à l'utiliser et l'exploiter dans les mêmes conditions de sécurité. Ce contrat peut être reproduit et diffusé librement, sous réserve de le conserver en l'état, sans ajout ni suppression de clauses.

Ce contrat est susceptible de s'appliquer à tout logiciel dont le titulaire des droits patrimoniaux décide de soumettre l'exploitation aux dispositions qu'il contient.

Article 1 - DEFINITIONS

Dans ce contrat, les termes suivants, lorsqu'ils seront écrits avec une lettre capitale, auront la signification suivante:

Contrat: désigne le présent contrat de licence, ses éventuelles versions postérieures et annexes.

Logiciel: désigne le logiciel sous sa forme de Code Objet et/ou de Code Source et le cas échéant sa documentation, dans leur état au moment de l'acceptation du Contrat par le Licencié.

Logiciel Initial: désigne le Logiciel sous sa forme de Code Source et éventuellement de Code Objet et le cas échéant sa documentation, dans leur état au moment de leur première diffusion sous les termes du Contrat.

Logiciel Modifié: désigne le Logiciel modifié par au moins une Contribution.

Code Source: désigne l'ensemble des instructions et des lignes de programme du Logiciel et auquel l'accès est nécessaire en vue de modifier le Logiciel.

Code Objet: désigne les fichiers binaires issus de la compilation du Code Source.

Titulaire: désigne le ou les détenteurs des droits patrimoniaux d'auteur sur le Logiciel Initial.

Licencié: désigne le ou les utilisateurs du Logiciel ayant accepté le Contrat.

Contributeur: désigne le Licencié auteur d'au moins une Contribution.

Concédant: désigne le Titulaire ou toute personne physique ou morale distribuant le Logiciel sous le Contrat.

Contribution: désigne l'ensemble des modifications, corrections, traductions, adaptations et/ou nouvelles fonctionnalités intégrées dans le Logiciel par tout Contributeur, ainsi que tout Module Interne.

Module: désigne un ensemble de fichiers sources y compris leur documentation qui permet de réaliser des fonctionnalités ou services supplémentaires à ceux fournis par le Logiciel.

Module Externe: désigne tout Module, non dérivé du Logiciel, tel que ce Module et le Logiciel s'exécutent dans des espaces d'adressage différents, l'un appelant l'autre au moment de leur exécution.

Module Interne: désigne tout Module lié au Logiciel de telle sorte qu'ils s'exécutent dans le même espace d'adressage.

Parties: désigne collectivement le Licencié et le Concédant.

Ces termes s'entendent au singulier comme au pluriel.

Article 2 - OBJET

Le Contrat a pour objet la concession par le Concédant au Licencié d'une licence non exclusive, cessible et mondiale du Logiciel telle que définie ci-après à l'article 5 pour toute la durée de protection des droits portant sur ce Logiciel.

Article 3 - ACCEPTATION

3.1 L'acceptation par le Licencié des termes du Contrat est réputée acquise du fait du premier des faits suivants:

(i) le chargement du Logiciel par tout moyen notamment par téléchargement à partir d'un serveur distant ou par chargement à partir d'un support physique;
(ii) le premier exercice par le Licencié de l'un quelconque des droits concédés par le Contrat.
3.2 Un exemplaire du Contrat, contenant notamment un avertissement relatif aux spécificités du Logiciel, à la restriction de garantie et à la limitation à un usage par des utilisateurs expérimentés a été mis à disposition du Licencié préalablement à son acceptation telle que définie à l'article 3.1 ci dessus et le Licencié reconnaît en avoir pris connaissance.

Article 4 - ENTREE EN VIGUEUR ET DUREE

4.1 ENTREE EN VIGUEUR

Le Contrat entre en vigueur à la date de son acceptation par le Licencié telle que définie en 3.1.

4.2 DUREE

Le Contrat produira ses effets pendant toute la durée légale de protection des droits patrimoniaux portant sur le Logiciel.

Article 5 - ETENDUE DES DROITS CONCEDES

Le Concédant concède au Licencié, qui accepte, les droits suivants sur le Logiciel pour toutes destinations et pour la durée du Contrat dans les conditions ci-après détaillées.

Par ailleurs, si le Concédant détient ou venait à détenir un ou plusieurs brevets d'invention protégeant tout ou partie des fonctionnalités du Logiciel ou de ses composants, il s'engage à ne pas opposer les éventuels droits conférés par ces brevets aux Licenciés successifs qui utiliseraient, exploiteraient ou modifieraient le Logiciel. En cas de cession de ces brevets, le Concédant s'engage à faire reprendre les obligations du présent alinéa aux cessionnaires.

5.1 DROIT D'UTILISATION

Le Licencié est autorisé à utiliser le Logiciel, sans restriction quant aux domaines d'application, étant ci-après précisé que cela comporte:

la reproduction permanente ou provisoire du Logiciel en tout ou partie par tout moyen et sous toute forme.

le chargement, l'affichage, l'exécution, ou le stockage du Logiciel sur tout support.

la possibilité d'en observer, d'en étudier, ou d'en tester le fonctionnement afin de déterminer les idées et principes qui sont à la base de n'importe quel élément de ce Logiciel; et ceci, lorsque le Licencié effectue toute opération de chargement, d'affichage, d'exécution, de transmission ou de stockage du Logiciel qu'il est en droit d'effectuer en vertu du Contrat.

5.2 DROIT D'APPORTER DES CONTRIBUTIONS

Le droit d'apporter des Contributions comporte le droit de traduire, d'adapter, d'arranger ou d'apporter toute autre modification au Logiciel et le droit de reproduire le logiciel en résultant.

Le Licencié est autorisé à apporter toute Contribution au Logiciel sous réserve de mentionner, de façon explicite, son nom en tant qu'auteur de cette Contribution et la date de création de celle-ci.

5.3 DROIT DE DISTRIBUTION

Le droit de distribution comporte notamment le droit de diffuser, de transmettre et de communiquer le Logiciel au public sur tout support et par tout moyen ainsi que le droit de mettre sur le marché à titre onéreux ou gratuit, un ou des exemplaires du Logiciel par tout procédé.

Le Licencié est autorisé à distribuer des copies du Logiciel, modifié ou non, à des tiers dans les conditions ci-après détaillées.

5.3.1 DISTRIBUTION DU LOGICIEL SANS MODIFICATION

Le Licencié est autorisé à distribuer des copies conformes du Logiciel, sous forme de Code Source ou de Code Objet, à condition que cette distribution respecte les dispositions du Contrat dans leur totalité et soit accompagnée:

d'un exemplaire du Contrat,

d'un avertissement relatif à la restriction de garantie et de responsabilité du Concédant telle que prévue aux articles 8 et 9,

et que, dans le cas où seul le Code Objet du Logiciel est redistribué, le Licencié permette un accès effectif au Code Source complet du Logiciel pendant au moins toute la durée de sa distribution du Logiciel, étant entendu que le coût additionnel d'acquisition du Code Source ne devra pas excéder le simple coût de transfert des données.

5.3.2 DISTRIBUTION DU LOGICIEL MODIFIE

Lorsque le Licencié apporte une Contribution au Logiciel, le Logiciel Modifié peut être distribué sous un contrat de licence autre que le présent Contrat sous réserve du respect des dispositions de l'article 5.3.4.

5.3.3 DISTRIBUTION DES MODULES EXTERNES

Lorsque le Licencié a développé un Module Externe les conditions du Contrat ne s'appliquent pas à ce Module Externe, qui peut être distribué sous un contrat de licence différent.

5.3.4 CITATIONS

Le Licencié qui distribue un Logiciel Modifié s'engage expressément:

à indiquer dans sa documentation qu'il a été réalisé à partir du Logiciel régi par le Contrat, en reproduisant les mentions de propriété intellectuelle du Logiciel,

à faire en sorte que l'utilisation du Logiciel, ses mentions de propriété intellectuelle et le fait qu'il est régi par le Contrat soient indiqués dans un texte facilement accessible depuis l'interface du Logiciel Modifié,

à mentionner, sur un site Web librement accessible décrivant le Logiciel Modifié, et pendant au moins toute la durée de sa distribution, qu'il a été réalisé à partir du Logiciel régi par le Contrat, en reproduisant les mentions de propriété intellectuelle du Logiciel,

lorsqu'il le distribue à un tiers susceptible de distribuer lui-même un Logiciel Modifié, sans avoir à en distribuer le code source, à faire ses meilleurs efforts pour que les obligations du présent article 5.3.4 soient reprises par le dit tiers.

Lorsque le Logiciel modifié ou non est distribué avec un Module Externe qui a été conçu pour l'utiliser, le Licencié doit soumettre le dit Module Externe aux obligations précédentes.

5.3.5 COMPATIBILITE AVEC LES LICENCES CeCILL et CeCILL-C

Lorsqu'un Logiciel Modifié contient une Contribution soumise au contrat de licence CeCILL, les stipulations prévues à l'article 5.3.4 sont facultatives.

Un Logiciel Modifié peut être distribué sous le contrat de licence CeCILL-C. Les stipulations prévues à l'article 5.3.4 sont alors facultatives.

Article 6 - PROPRIETE INTELLECTUELLE

6.1 SUR LE LOGICIEL INITIAL

Le Titulaire est détenteur des droits patrimoniaux sur le Logiciel Initial. Toute utilisation du Logiciel Initial est soumise au respect des conditions dans lesquelles le Titulaire a choisi de diffuser son oeuvre et nul autre n'a la faculté de modifier les conditions de diffusion de ce Logiciel Initial.

Le Titulaire s'engage à ce que le Logiciel Initial reste au moins régi par le Contrat et ce, pour la durée visée à l'article 4.2.

6.2 SUR LES CONTRIBUTIONS

Le Licencié qui a développé une Contribution est titulaire sur celle-ci des droits de propriété intellectuelle dans les conditions définies par la législation applicable.

6.3 SUR LES MODULES EXTERNES

Le Licencié qui a développé un Module Externe est titulaire sur celui-ci des droits de propriété intellectuelle dans les conditions définies par la législation applicable et reste libre du choix du contrat régissant sa diffusion.

6.4 DISPOSITIONS COMMUNES

Le Licencié s'engage expressément:

à ne pas supprimer ou modifier de quelque manière que ce soit les mentions de propriété intellectuelle apposées sur le Logiciel;

à reproduire à l'identique lesdites mentions de propriété intellectuelle sur les copies du Logiciel modifié ou non.

Le Licencié s'engage à ne pas porter atteinte, directement ou indirectement, aux droits de propriété intellectuelle du Titulaire et/ou des Contributeurs sur le Logiciel et à prendre, le cas échéant, à l'égard de son personnel toutes les mesures nécessaires pour assurer le respect des dits droits de propriété intellectuelle du Titulaire et/ou des Contributeurs.

Article 7 - SERVICES ASSOCIES

7.1 Le Contrat n'oblige en aucun cas le Concédant à la réalisation de prestations d'assistance technique ou de maintenance du Logiciel.

Cependant le Concédant reste libre de proposer ce type de services. Les termes et conditions d'une telle assistance technique et/ou d'une telle maintenance seront alors déterminés dans un acte séparé. Ces actes de maintenance et/ou assistance technique n'engageront que la seule responsabilité du Concédant qui les propose.

7.2 De même, tout Concédant est libre de proposer, sous sa seule responsabilité, à ses licenciés une garantie, qui n'engagera que lui, lors de la redistribution du Logiciel et/ou du Logiciel Modifié et ce, dans les conditions qu'il souhaite. Cette garantie et les modalités financières de son application feront l'objet d'un acte séparé entre le Concédant et le Licencié.

Article 8 - RESPONSABILITE

8.1 Sous réserve des dispositions de l'article 8.2, le Licencié a la faculté, sous réserve de prouver la faute du Concédant concerné, de solliciter la réparation du préjudice direct qu'il subirait du fait du Logiciel et dont il apportera la preuve.

8.2 La responsabilité du Concédant est limitée aux engagements pris en application du Contrat et ne saurait être engagée en raison notamment: (i) des dommages dus à l'inexécution, totale ou partielle, de ses obligations par le Licencié, (ii) des dommages directs ou indirects découlant de l'utilisation ou des performances du Logiciel subis par le Licencié et (iii) plus généralement d'un quelconque dommage indirect. En particulier, les Parties conviennent expressément que tout préjudice financier ou commercial (par exemple perte de données, perte de bénéfices, perte d'exploitation, perte de clientèle ou de commandes, manque à gagner, trouble commercial quelconque) ou toute action dirigée contre le Licencié par un tiers, constitue un dommage indirect et n'ouvre pas droit à réparation par le Concédant.

Article 9 - GARANTIE

9.1 Le Licencié reconnaît que l'état actuel des connaissances scientifiques et techniques au moment de la mise en circulation du Logiciel ne permet pas d'en tester et d'en vérifier toutes les utilisations ni de détecter l'existence d'éventuels défauts. L'attention du Licencié a été attirée sur ce point sur les risques associés au chargement, à l'utilisation, la modification et/ou au développement et à la reproduction du Logiciel qui sont réservés à des utilisateurs avertis.

Il relève de la responsabilité du Licencié de contrôler, par tous moyens, l'adéquation du produit à ses besoins, son bon fonctionnement et de s'assurer qu'il ne causera pas de dommages aux personnes et aux biens.

9.2 Le Concédant déclare de bonne foi être en droit de concéder l'ensemble des droits attachés au Logiciel (comprenant notamment les droits visés à l'article 5).

9.3 Le Licencié reconnaît que le Logiciel est fourni \"en l'état\" par le Concédant sans autre garantie, expresse ou tacite, que celle prévue à l'article 9.2 et notamment sans aucune garantie sur sa valeur commerciale, son caractère sécurisé, innovant ou pertinent.

En particulier, le Concédant ne garantit pas que le Logiciel est exempt d'erreur, qu'il fonctionnera sans interruption, qu'il sera compatible avec l'équipement du Licencié et sa configuration logicielle ni qu'il remplira les besoins du Licencié.

9.4 Le Concédant ne garantit pas, de manière expresse ou tacite, que le Logiciel ne porte pas atteinte à un quelconque droit de propriété intellectuelle d'un tiers portant sur un brevet, un logiciel ou sur tout autre droit de propriété. Ainsi, le Concédant exclut toute garantie au profit du Licencié contre les actions en contrefaçon qui pourraient être diligentées au titre de l'utilisation, de la modification, et de la redistribution du Logiciel. Néanmoins, si de telles actions sont exercées contre le Licencié, le Concédant lui apportera son aide technique et juridique pour sa défense. Cette aide technique et juridique est déterminée au cas par cas entre le Concédant concerné et le Licencié dans le cadre d'un protocole d'accord. Le Concédant dégage toute responsabilité quant à l'utilisation de la dénomination du Logiciel par le Licencié. Aucune garantie n'est apportée quant à l'existence de droits antérieurs sur le nom du Logiciel et sur l'existence d'une marque.

Article 10 - RESILIATION

10.1 En cas de manquement par le Licencié aux obligations mises à sa charge par le Contrat, le Concédant pourra résilier de plein droit le Contrat trente (30) jours après notification adressée au Licencié et restée sans effet.

10.2 Le Licencié dont le Contrat est résilié n'est plus autorisé à utiliser, modifier ou distribuer le Logiciel. Cependant, toutes les licences qu'il aura concédées antérieurement à la résiliation du Contrat resteront valides sous réserve qu'elles aient été effectuées en conformité avec le Contrat.

Article 11 - DISPOSITIONS DIVERSES

11.1 CAUSE EXTERIEURE

Aucune des Parties ne sera responsable d'un retard ou d'une défaillance d'exécution du Contrat qui serait dû à un cas de force majeure, un cas fortuit ou une cause extérieure, telle que, notamment, le mauvais fonctionnement ou les interruptions du réseau électrique ou de télécommunication, la paralysie du réseau liée à une attaque informatique, l'intervention des autorités gouvernementales, les catastrophes naturelles, les dégâts des eaux, les tremblements de terre, le feu, les explosions, les grèves et les conflits sociaux, l'état de guerre...

11.2 Le fait, par l'une ou l'autre des Parties, d'omettre en une ou plusieurs occasions de se prévaloir d'une ou plusieurs dispositions du Contrat, ne pourra en aucun cas impliquer renonciation par la Partie intéressée à s'en prévaloir ultérieurement.

11.3 Le Contrat annule et remplace toute convention antérieure, écrite ou orale, entre les Parties sur le même objet et constitue l'accord entier entre les Parties sur cet objet. Aucune addition ou modification aux termes du Contrat n'aura d'effet à l'égard des Parties à moins d'être faite par écrit et signée par leurs représentants dûment habilités.

11.4 Dans l'hypothèse où une ou plusieurs des dispositions du Contrat s'avèrerait contraire à une loi ou à un texte applicable, existants ou futurs, cette loi ou ce texte prévaudrait, et les Parties feraient les amendements nécessaires pour se conformer à cette loi ou à ce texte. Toutes les autres dispositions resteront en vigueur. De même, la nullité, pour quelque raison que ce soit, d'une des dispositions du Contrat ne saurait entraîner la nullité de l'ensemble du Contrat.

11.5 LANGUE

Le Contrat est rédigé en langue française et en langue anglaise, ces deux versions faisant également foi.

Article 12 - NOUVELLES VERSIONS DU CONTRAT

12.1 Toute personne est autorisée à copier et distribuer des copies de ce Contrat.

12.2 Afin	d'en préserver la cohérence, le texte du Contrat est protégé et ne peut être modifié que par les auteurs de la licence, lesquels se réservent le droit de publier périodiquement des mises à jour ou de nouvelles versions du Contrat, qui posséderont chacune un numéro distinct. Ces versions ultérieures seront susceptibles de prendre en compte de nouvelles problématiques rencontrées par les logiciels libres.

12.3 Tout Logiciel diffusé sous une version donnée du Contrat ne pourra faire l'objet d'une diffusion ultérieure que sous la même version du Contrat ou une version postérieure.

Article 13 - LOI APPLICABLE ET COMPETENCE TERRITORIALE

13.1 Le Contrat est régi par la loi française. Les Parties conviennent de tenter de régler à l'amiable les différends ou litiges qui viendraient à se produire par suite ou à l'occasion du Contrat.

13.2 A défaut d'accord amiable dans un délai de deux (2) mois à compter de leur survenance et sauf situation relevant d'une procédure d'urgence, les différends ou litiges seront portés par la Partie la plus diligente devant les Tribunaux compétents de Paris.

-------------------------- Englidh version --------------------------


CeCILL-B FREE SOFTWARE LICENSE AGREEMENT

Version 1.0 dated 2006-09-05.

Notice

This Agreement is a Free Software license agreement that is the result of discussions between its authors in order to ensure compliance with the two main principles guiding its drafting:

firstly, compliance with the principles governing the distribution of Free Software: access to source code, broad rights granted to users,
secondly, the election of a governing law, French law, with which it is conformant, both as regards the law of torts and intellectual property law, and the protection that it offers to both authors and holders of the economic rights over software.
The authors of the CeCILL-B1 license are:

Commissariat à l'Energie Atomique - CEA, a public scientific, technical and industrial research establishment, having its principal place of business at 25 rue Leblanc, immeuble Le Ponant D, 75015 Paris, France.

Centre National de la Recherche Scientifique - CNRS, a public scientific and technological establishment, having its principal place of business at 3 rue Michel-Ange, 75794 Paris cedex 16, France.

Institut National de Recherche en Informatique et en Automatique - INRIA, a public scientific and technological establishment, having its principal place of business at Domaine de Voluceau, Rocquencourt, BP 105, 78153 Le Chesnay cedex, France.

Preamble

This Agreement is an open source software license intended to give users significant freedom to modify and redistribute the software licensed hereunder.

The exercising of this freedom is conditional upon a strong obligation of giving credits for everybody that distributes a software incorporating a software ruled by the current license so as all contributions to be properly identified and acknowledged.

In consideration of access to the source code and the rights to copy, modify and redistribute granted by the license, users are provided only with a limited warranty and the software's author, the holder of the economic rights, and the successive licensors only have limited liability.

In this respect, the risks associated with loading, using, modifying and/or developing or reproducing the software by the user are brought to the user's attention, given its Free Software status, which may make it complicated to use, with the result that its use is reserved for developers and experienced professionals having in-depth computer knowledge. Users are therefore encouraged to load and test the suitability of the software as regards their requirements in conditions enabling the security of their systems and/or data to be ensured and, more generally, to use and operate it in the same conditions of security. This Agreement may be freely reproduced and published, provided it is not altered, and that no provisions are either added or removed herefrom.

This Agreement may apply to any or all software for which the holder of the economic rights decides to submit the use thereof to its provisions.

Article 1 - DEFINITIONS

For the purpose of this Agreement, when the following expressions commence with a capital letter, they shall have the following meaning:

Agreement: means this license agreement, and its possible subsequent versions and annexes.

Software: means the software in its Object Code and/or Source Code form and, where applicable, its documentation, \"as is\" when the Licensee accepts the Agreement.

Initial Software: means the Software in its Source Code and possibly its Object Code form and, where applicable, its documentation, \"as is\" when it is first distributed under the terms and conditions of the Agreement.

Modified Software: means the Software modified by at least one Contribution.

Source Code: means all the Software's instructions and program lines to which access is required so as to modify the Software.

Object Code: means the binary files originating from the compilation of the Source Code.

Holder: means the holder(s) of the economic rights over the Initial Software.

Licensee: means the Software user(s) having accepted the Agreement.

Contributor: means a Licensee having made at least one Contribution.

Licensor: means the Holder, or any other individual or legal entity,	who distributes the Software under the Agreement.

Contribution: means any or all modifications, corrections, translations, adaptations and/or new functions integrated into the Software by any or all Contributors, as well as any or all Internal Modules.

Module: means a set of sources files including their documentation that enables supplementary functions or services in addition to those offered by the Software.

External Module: means any or all Modules, not derived from the Software, so that this Module and the	Software run in separate address spaces, with one calling the other when they are run.

Internal Module: means any or all Module, connected to the Software so that they both execute in the same address space.

Parties: mean both the Licensee and the Licensor.

These expressions may be used both in singular and plural form.

Article 2 - PURPOSE

The purpose of the Agreement is the grant by the Licensor to the Licensee of a non-exclusive, transferable and worldwide license for the	Software as set forth in Article 5 hereinafter for the whole term of the protection granted by the rights over said Software.

Article 3 - ACCEPTANCE

3.1 The Licensee shall be deemed as having accepted the terms and conditions of this Agreement upon the occurrence of the first of the following events:

(i) loading the Software by any or all means, notably, by downloading from a remote server, or by loading from a physical medium;
(ii) the first time the Licensee exercises any of the rights granted hereunder.
3.2 One copy of the Agreement, containing a notice relating to the characteristics of the Software, to the limited warranty, and to the fact that its use is restricted to experienced users has been provided to the Licensee prior to its acceptance as set forth in Article 3.1 hereinabove, and the Licensee hereby acknowledges that it has read and understood it.

Article 4 - EFFECTIVE DATE AND TERM

4.1 EFFECTIVE DATE

The Agreement shall become effective on the date when it is accepted by the Licensee as set forth in Article 3.1.

4.2 TERM

The Agreement shall remain in force for the entire legal term of protection of the economic rights over the Software.

Article 5 - SCOPE OF RIGHTS GRANTED

The Licensor hereby grants to the Licensee, who accepts, the following rights over the Software for any or all use, and for the term of the Agreement, on the basis of the terms and conditions set forth hereinafter.

Besides, if the Licensor owns or comes to own one or more patents protecting all or part of the functions of the Software or of its components, the Licensor undertakes not to enforce the rights granted by these patents against successive Licensees using, exploiting or modifying the Software. If these patents are transferred, the Licensor undertakes to have the transferees subscribe to the obligations set forth in this paragraph.

5.1 RIGHT OF USE

The Licensee is authorized to use the Software, without any limitation as to its fields of application, with it being hereinafter specified that this comprises:

permanent or temporary reproduction of all or part of the Software by any or all means and in any or all form.

loading, displaying, running, or storing the Software on any or all medium.

entitlement to observe, study or test its operation so as to determine the ideas and principles behind any or all constituent elements of said Software. This shall apply when the Licensee carries out any or all loading, displaying, running, transmission or storage operation as regards the Software, that it is entitled to carry out hereunder.

5.2 ENTITLEMENT TO MAKE CONTRIBUTIONS

The right to make Contributions includes the right to translate, adapt, arrange, or make any or all modifications to the Software, and the right to reproduce the resulting software.

The Licensee is authorized to make any or all Contributions to the Software provided that it includes an explicit notice that it is the author of said Contribution and indicates the date of the creation thereof.

5.3 RIGHT OF DISTRIBUTION

In particular, the right of distribution includes the right to publish, transmit and communicate the Software to the general public on any or all medium, and by any or all means, and the right to market, either in consideration of a fee, or free of charge, one or more copies of the Software by any means.

The Licensee is further authorized to distribute copies of the modified or unmodified Software to third parties according to the terms and conditions set forth hereinafter.

5.3.1 DISTRIBUTION OF SOFTWARE WITHOUT MODIFICATION

The Licensee is authorized to distribute true copies of the Software in Source Code or Object Code form, provided that said distribution complies with all the provisions of the Agreement and is accompanied by:

a copy of the Agreement,

a notice relating to the limitation of both the Licensor's warranty and liability as set forth in Articles 8 and 9,

and that, in the event that only the Object Code of the Software is redistributed, the Licensee allows effective access to the full Source Code of the Software at a minimum during the entire period of its distribution of the Software, it being understood that the additional cost of acquiring the Source Code shall not exceed the cost of transferring the data.

5.3.2 DISTRIBUTION OF MODIFIED SOFTWARE

If the Licensee makes any Contribution to the Software, the resulting Modified Software may be distributed under a license agreement other than this Agreement subject to compliance with the provisions of Article 5.3.4.

5.3.3 DISTRIBUTION OF EXTERNAL MODULES

When the Licensee has developed an External Module, the terms and conditions of this Agreement do not apply to said External Module, that may be distributed under a separate license agreement.

5.3.4 CREDITS

Any Licensee who may distribute a Modified Software hereby expressly agrees to:

indicate in the related documentation that it is based on the Software licensed hereunder, and reproduce the intellectual property notice for the Software,

ensure that written indications of the Software intended use, intellectual property notice and license hereunder are included in easily accessible format from the Modified Software interface,

mention, on a freely accessible website describing the Modified Software, at least throughout the distribution term thereof, that it is based on the Software licensed hereunder, and reproduce the Software intellectual property notice,

where it is distributed to a third party that may distribute a Modified Software without having to make its source code available, make its best efforts to ensure that said third party agrees to comply with the obligations set forth in this Article .

If the Software, whether or not modified, is distributed with an External Module designed for use in connection with the Software, the Licensee shall submit said External Module to the foregoing obligations.

5.3.5 COMPATIBILITY WITH THE CeCILL AND CeCILL-C LICENSES

Where a Modified Software contains a Contribution subject to the CeCILL license, the provisions set forth in Article 5.3.4 shall be optional.

A Modified Software may be distributed under the CeCILL-C license. In such a case the provisions set forth in Article 5.3.4 shall be optional.

Article 6 - INTELLECTUAL PROPERTY

6.1 OVER THE INITIAL SOFTWARE

The Holder owns the economic rights over the Initial Software. Any or all use of the Initial Software is subject to compliance with the terms and conditions under which the Holder has elected to distribute its work and no one shall be entitled to modify the terms and conditions for the distribution of said Initial Software.

The Holder undertakes that the Initial Software will remain ruled at least by this Agreement, for the duration set forth in Article 4.2.

6.2 OVER THE CONTRIBUTIONS

The Licensee who develops a Contribution is the owner of the intellectual property rights over this Contribution as defined by applicable law.

6.3 OVER THE EXTERNAL MODULES

The Licensee who develops an External Module is the owner of the intellectual property rights over this External Module as defined by applicable law and is free to	choose the type of agreement that shall govern its distribution.

6.4 JOINT PROVISIONS

The Licensee expressly undertakes:

not to remove, or modify, in any manner, the intellectual property notices attached to the Software;

to reproduce said notices, in an identical manner, in the copies of the Software modified or not.

The Licensee undertakes not to directly or indirectly infringe the intellectual property rights of the Holder and/or Contributors on the Software and to take, where applicable, vis-à-vis its staff, any and all measures required to ensure respect of said intellectual property rights of the Holder and/or Contributors.

Article 7 - RELATED SERVICES

7.1 Under no circumstances shall the Agreement oblige the Licensor to provide technical assistance or maintenance services for the Software.

However, the Licensor is entitled to offer this type of services. The terms and conditions of such technical assistance, and/or such maintenance, shall be set forth in a separate instrument. Only the Licensor offering said maintenance and/or technical assistance services shall incur liability therefor.

7.2 Similarly, any Licensor is entitled to offer to its licensees, under its sole responsibility, a warranty, that shall only be binding upon itself, for the redistribution of the Software and/or the Modified Software, under terms and conditions that it is free to decide. Said warranty, and the financial terms and conditions of its application, shall be subject of a separate instrument executed between the Licensor and the Licensee.

Article 8 - LIABILITY

8.1 Subject to the provisions of Article 8.2, the Licensee shall be entitled to claim compensation for any direct loss it may have suffered from the Software as a result of a fault on the part of the relevant Licensor, subject to providing evidence thereof.

8.2 The Licensor's liability is limited to the commitments made under this Agreement and shall not be incurred as a result of in particular: (i) loss due the Licensee's total or partial failure to fulfill its obligations, (ii) direct or consequential loss that is suffered by the Licensee due to the use or performance of the Software, and (iii) more generally, any consequential loss. In particular the Parties expressly agree that any or all pecuniary or business loss (i.e. loss of data, loss of profits, operating loss, loss of customers or orders, opportunity cost, any disturbance to business activities) or any or all legal proceedings instituted against the Licensee by a third party, shall constitute consequential loss and shall not provide entitlement to any or all compensation from the Licensor.

Article 9 - WARRANTY

9.1 The Licensee acknowledges that the scientific and technical state-of-the-art when the Software was distributed did not enable all possible uses to be tested and verified, nor for the presence of possible defects to be detected. In this respect, the Licensee's attention has been drawn to the risks associated with loading, using, modifying and/or developing and reproducing the Software which are reserved for experienced users.

The Licensee shall be responsible for verifying, by any or all means, the suitability of the product for its requirements, its good working order, and for ensuring that it shall not cause damage to either persons or properties.

9.2 The Licensor hereby represents, in good faith, that it is entitled to grant all the rights over the Software (including in particular the rights set forth in Article 5).

9.3 The Licensee acknowledges that the Software is supplied \"as is\" by the Licensor without any other express or tacit warranty, other than that provided for in Article 9.2 and, in particular, without any warranty as to its commercial value, its secured, safe, innovative or relevant nature.

Specifically, the Licensor does not warrant that the Software is free from any error, that it will operate without interruption, that it will be compatible with the Licensee's own equipment and software configuration, nor that it will meet the Licensee's requirements.

9.4 The Licensor does not either expressly or tacitly warrant that the Software does not infringe any third party intellectual property right relating to a patent, software or any other property right. Therefore, the Licensor disclaims any and all liability towards the Licensee arising out of any or all proceedings for infringement that may be instituted in respect of the use, modification and redistribution of the Software. Nevertheless, should such proceedings be instituted against the Licensee, the Licensor shall provide it with technical and legal assistance for its defense. Such technical and legal assistance shall be decided on a case-by-case basis between the relevant Licensor and the Licensee pursuant to a memorandum of understanding. The Licensor disclaims any and all liability as regards the Licensee's use of the name of the Software. No warranty is given as regards the existence of prior rights over the name of the Software or as regards the existence of a trademark.

Article 10 - TERMINATION

10.1 In the event of a breach by the Licensee of its obligations hereunder, the Licensor may automatically terminate this Agreement thirty (30) days after notice has been sent to the Licensee and has remained ineffective.

10.2 A Licensee whose Agreement is terminated shall no longer be authorized to use, modify or distribute the Software. However, any licenses that it may have granted prior to termination of the Agreement shall remain valid subject to their having been granted in compliance with the terms and conditions hereof.

Article 11 - MISCELLANEOUS

11.1 EXCUSABLE EVENTS

Neither Party shall be liable for any or all delay, or failure to perform the Agreement, that may be attributable to an event of force majeure, an act of God or an outside cause, such as defective functioning or interruptions of the electricity or telecommunications networks, network paralysis following a virus attack, intervention by government authorities,	natural disasters, water damage, earthquakes, fire, explosions, strikes and labor unrest, war, etc.

11.2 Any failure by either Party, on one or more occasions, to invoke one or more of the provisions hereof, shall under no circumstances be interpreted as being a waiver by the interested Party of its right to invoke said provision(s) subsequently.

11.3 The Agreement cancels and replaces any or all previous agreements, whether written or oral, between the Parties and having the same purpose, and constitutes the entirety of the agreement between said Parties concerning said purpose. No supplement or modification to the terms and conditions hereof shall be effective as between the Parties unless it is made in writing and signed by their duly authorized representatives.

11.4 In the event that one or more of the provisions hereof were to conflict with a current or future applicable act or legislative text, said act or legislative text shall prevail, and the Parties shall make the necessary amendments so as to comply with said act or legislative text. All other provisions shall remain effective. Similarly, invalidity of a provision of the Agreement, for any reason whatsoever, shall not cause the Agreement as a whole to be invalid.

11.5 LANGUAGE

The Agreement is drafted in both French and English and both versions are deemed authentic.

Article 12 - NEW VERSIONS OF THE AGREEMENT

12.1 Any person is authorized to duplicate and distribute copies of this Agreement.

12.2 So as to ensure coherence, the wording of this Agreement is protected and may only be modified by the authors of the License, who reserve the right to periodically publish updates or new versions of the Agreement, each with a separate number. These subsequent versions may address new issues encountered by Free Software.

12.3 Any Software distributed under a given version of the Agreement may only be subsequently distributed under the same version of the Agreement or a subsequent version.

Article 13 - GOVERNING LAW AND JURISDICTION

13.1 The Agreement is governed by French law. The Parties agree to endeavor to seek an amicable solution to any disagreements or disputes that may arise during the performance of the Agreement.

13.2 Failing an amicable solution within two (2) months as from their occurrence, and unless emergency proceedings are necessary, the disagreements or disputes shall be referred to the Paris Courts having jurisdiction, by the more diligent Party.

")
