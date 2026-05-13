<p align="center"> <img width="828" height="320" alt="banner" src="https://github.com/user-attachments/assets/62e103a6-bf82-4af4-ba88-900132581d23" /> </p>

# Captures d'écrans
<img width="500"  alt="Capture d&#39;écran 2026-04-02 230840" src="https://github.com/user-attachments/assets/55e6d8c6-5a29-491c-b8de-518d95cbacdf" />
<img width="500" height="383" alt="Nouvelle traj Camera bleu" src="https://github.com/user-attachments/assets/4d3ccc75-c43a-4d74-8eef-5084099ac763" />
<img width="500" alt="Capture d&#39;écran 2026-03-29 192223" src="https://github.com/user-attachments/assets/a2b1b432-d5e2-4233-bec9-f663a43c7b26" />
<img width="500" height="293.103" alt="Capture d&#39;écran 2026-05-13 165151" src="https://github.com/user-attachments/assets/09da3f7e-e400-449e-a29e-916eac7aeb4f" />



# Résumé du projet
La problématique centrale consiste à concevoir une stratégie de navigation autonome et fiable pour le robot mobile QBot, en utilisant sa caméra RGB pour la planification et en fusionnant les données des capteurs pour assurer un suivi.

Ce projet se décline en 5 objectifs principaux :
- Modélisation : Développer un modèle mathématique cinématique du robot QBot adapté à sa navigation.
- Perception visuelle : Exploiter la caméra RGB pour détecter et identifier les obstacles/repères visuels en temps réel.
- Estimation d’état : Mettre en œuvre une méthode d’estimation (EKF) intégrant les informations de la caméra et des encodeurs embarqués.
- Loi de commande : Concevoir un contrôleur avancé (NMPC) garantissant un suivi de trajectoire fiable, fluide et précis.
- Validation : Tester la stratégie à travers une interface MATLAB/Simulink couplée au jumeau numérique QLabs, sur divers scénarios (ligne droite, carré, évitement).

Le projet a été entièrement réalisé sur MATLAB et Simulink.

# Installation et mise en route
## Prérequis
Pour pouvoir lancer le projet quanser, vous aurez besoin des logiciels et licenses suivantes:
- <a href="https://www.quanser.com/products/quanser-interactive-labs/"> Quanser interactive Labs</a>, avec une license incluant le Qbot platform
- une license MATLAB/Simulink incluant:
  - Simulink real-time
  - optimization toolbox
  - MATLAB Coder, SIMULINK Coder
  - Quanser interactive labs for MATLAB
  - d'autres add-ons sont peut être nécessaire
 
> [!IMPORTANT]  
> Certaines version de MATLAB fonctionnent plus ou moins bien avec le Quanser Interactive Labs, prioriser les versions "B" (ex: R2024B).

D'une manière générale, il est conseillé de suivre les instructions données dans les <a href="https://github.com/quanser/Quanser_Academic_Resources">Quanser Academic Resources</a>.

## Mise en place du projet MATLAB
Ce repository est un projet MATLAB, il est donc possible de le cloner. Pour plus d'informations sur comment  le mettre en place, se référer à <a href="https://youtu.be/3OZ67_Uar_0?si=NmtzBcwG9yaNe894">cette vidéo</a>.

Il est aussi possible d'utiliser un client git externe, télécharger en tant que zip puis décompresser le repo... tant que tout se trouve dans le même dossier cela devrait fonctionner 😺.

## Lancement

> [!IMPORTANT]  
> Effectuez toutes les étapes suivantes avec le Quanser Qlabs ouvert dans un environnement du qbot platform (Studio, plane ou warehouse)

Lors de la première exécution (et lors de chaque changement de carte) il est impératif de lancer en premier le fichier `map_creator.m`. Ce dernier va créer un fichier **indispensable** au bon fonctionnement du projet, `map.mat`.

Ensuite, il faut exécuter le fichier `init_V3.m`. Une fois sa bonne exécution, ouvrir et lancer le fichier Simulink `V8.slx`.

> [!NOTE]  
> Lors du lancement du fichier Simulink il est préférable de lancer via "Monitor & Tune", section HARDWARE, en ayant selectionné comme target Quarc `quarc_win64.tlc` pour windows, par exemple, plutot que "Run" de la section SIMULATION.

# Remerciements
Nous tenons en premier lieu à exprimer notre sincère gratitude à notre professeur 
encadrant, **M. Meziane LARBI**, pour la qualité de son encadrement tout au 
long de ce projet. Sa disponibilité, son exigence bienveillante et la richesse des 
connaissances qu'il nous a transmises ont été déterminantes dans l'aboutissement 
de ce travail. Ce projet n'aurait pas pu atteindre ce niveau de maturité 
sans ses conseils avisés et son suivi rigoureux.

Nous remercions également l'ensemble du corps enseignant du département Robotique 
et Mécatronique de **JUNIA HEI Lille**, dont les enseignements dispensés 
cette année nous ont fourni les fondements théoriques et pratiques nécessaires à 
la réalisation de ce projet. Les compétences acquises en automatique, en commande des systèmes et en robotique mobile constituent 
le socle sur lequel repose l'intégralité de notre démarche. C'est grâce à la 
qualité de ces formations que nous avons eu la chance et les moyens de travailler 
sur un projet de cette envergure.

Nous adressons également nos remerciements à **l'École d'Ingénieurs JUNIA 
HEI Lille** pour nous avoir offert un cadre de travail particulièrement propice au 
développement de ce projet. L'accès au laboratoire de robotique, la mise à 
disposition du matériel nécessaire — notamment la plateforme **Quanser QBot**
et les licences **MATLAB/Simulink** — ainsi que la qualité des conditions de 
travail ont grandement facilité notre progression tout au long de l'année.

Enfin, nous remercions chaleureusement nos camarades de promotion pour les 
échanges constructifs et le soutien mutuel dont nous avons bénéficié au fil de 
ces travaux.
