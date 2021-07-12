#!/usr/bin/env python
import sys
#Declaration du chemin du fichier a importer
sys.path.insert(1,'/home/pi/projet/Full_test/')

#Import de la methode neccessaire
from test_fonctionne import write_read

#Lancement du test et renvoi dans console du message
value,duree = write_read('mouvement')
print(value)
