#!/usr/bin/env python
# Import des modules
import RPi.GPIO as GPIO
import serial,time
import os

# Initialisation de la numerotation et des E/S
# Initialisation du capteur de presence au port 38
GPIO.setmode(GPIO.BOARD)
GPIO.setup(38, GPIO.IN)

# Initialisation des logs
path="~/projet/logger "
log=path

#Initialisation du temps de fonctionnement en seconde
timestbystart=0
timestby=0
dureestby=60

#Initialisation port Nano
arduino = serial.Serial(port='/dev/ttyS0', baudrate=9600, timeout=.1)

# Module de notification de proximité:
# Si on detecte un mouvement, on ecrit un message
def write_read(x):
    arduino.write(x.encode('ascii'))
    time.sleep(0.05)
# Lecture du port Rx et mesure de la durée de la présence
    data = arduino.readline()
    timestart=time.time()
    while not data:
        data = arduino.readline()
    timestop=time.time()
    duree=timestop-timestart
    return data, round(duree,2)

# Module mouvement: Démarrage lecture port GPIO38
def detection_mouvement():
    global log
    state = GPIO.input(38)
    if not state:
        # On écrit sur le port UART Tx et lit sur le port Rx de ttyS0
        time.sleep(0.02)  # Pause pour ne pas saturer le processeur
        msg='mouvement'
        value,duree = write_read(msg)
        print(value)
        # Gestion log
        gestion_logs(value,duree)

# Module signal: Lecture du port UART Rx de ttyS0 et
# mesure de la durée du signal
def detection_signal():
    global log
    signal = arduino.readline()
    if signal:
        timestart=time.time()
        while not signal:
            signal = arduino.readline()
        timestop=time.time()
        duree=timestop-timestart
        print(signal)
        # Debut de la gestion log
        gestion_logs(signal,duree)
    else:
        # Debut de la gestion du mode attente
        gestion_mem_stby()

#Module gestion du mode attente
def gestion_mem_stby():
    global log, timestby, timestbystart
# Condition if: Changement ou pas du mode attente
    if(log!=path+"2 "):
        mode="Nano sent me: standby"
        gestion_logs(mode,0)
        timestbystart = time.time()
    else:
        timestby = time.time()

# Gestion log: Démarrage du script shell pour dépôt sur git
def gestion_logs(mode,duree):
# Condition if: Attente de la validation du Nano
# de la détection signal, mouvement
    global log
    log = path
# Condition if: Savoir le mode a utiliser
    if(mode == b'Nano sent me: mouvement'):
        log = log + "3 " + str(round(duree,3))
    elif(mode == b'Nano sent me: signal\r\n'):
        log = log + "1 " + str(round(duree,7))
    elif(mode == "Nano sent me: standby"):
        log = log + "2 "
    os.system(log)
    return log

# Main: Si le nano actif, on vérifie les signaux des modules
if __name__ == '__main__':
# Test de la connexion du Nano au port du Raspberry PI
    if arduino.isOpen():
        print("{} connected!".format(arduino.port))
        try:
# Le systeme fonctionne tant que le mode attente ne depasse pas une minute
# Ou interrompu par une commande clavier
            while(timestby-timestbystart<dureestby):
                # Méthode détection mouvement
                detection_mouvement()
                # Méthode détection signal
                detection_signal()
                #print(log)
        except KeyboardInterrupt:
            print("KeyboardInterrupt has been caught.")
    else:
        print("{} does not answer!".format(arduino.port))
