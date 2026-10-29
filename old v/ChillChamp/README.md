# ChillChamp — starter Android project

App Android nativa (Kotlin + Jetpack Compose) per mini-giochi tra amici. Include schermate Gruppi / Settings / Statistiche, struttura Firebase Auth + Cloud Firestore, creazione gruppi, codici invito di 8 caratteri con scadenza a 24 ore e 10 mini-giochi dimostrativi.

## Importante: stato del progetto

Questo è un **progetto sorgente iniziale**, non un APK già installabile. In questo ambiente non è disponibile Android SDK/Gradle per compilare l'APK e non posso configurare un progetto Firebase al posto tuo senza le credenziali/configurazioni del progetto. Le schermate e i mini-giochi sono dimostrativi; non considerare ancora completate la classifica competitiva server-side, i due tentativi ufficiali, la terza chance per gli ultimi, la chiusura del campionato, né la rigenerazione sicura degli inviti. Non usare dati sensibili o un gruppo reale finché non si aggiungono e testano le regole di sicurezza e la logica server.

## Come prepararla con Firebase

1. Installa Android Studio sul computer e apri questa cartella come progetto Gradle.
2. Crea un progetto in Firebase Console.
3. Registra un'app Android con package `it.chillchamp.app` e scarica `google-services.json` nella cartella `app/`.
4. In Firebase Authentication abilita il provider **Google**.
5. Prendi il **Web client ID** dalla configurazione di Google/Firebase e sostituisci `WEB_CLIENT_ID` in `MainActivity.kt` con quel valore.
6. Crea il database Cloud Firestore. Prima di usare l'app, configura regole Firestore restrittive e testale con Firebase Emulator Suite. Non pubblicare con regole aperte.
7. In Android Studio seleziona **Build > Build APK(s)**. Il file di debug, se la build va a buon fine, si trova in `app/build/outputs/apk/debug/app-debug.apk`.
8. Trasferisci l'APK sul telefono Android, aprilo e consenti l'installazione da quella sorgente quando richiesto.

## Architettura proposta per la versione completa

- Firebase Authentication: accesso Google.
- Cloud Firestore: profili, gruppi, membri, inviti, risultati, classifica giornaliera e campionati.
- Cloud Functions (consigliate): generazione atomica di codici invito unici, scadenze basate sull'orario server, conteggio dei tentativi, validazione dei punteggi, calcolo classifiche e chiusura del campionato.
- Gli inviti dovrebbero essere documenti con ID casuale univoco, scadenza server-side a 24 ore e revoca/rotazione. Il codice mostrato nell'interfaccia non è una misura di sicurezza da solo.

## Regole di gioco suggerite

- Campionato: 21 giorni dal momento in cui il creatore lo avvia, con timezone UTC lato server.
- Un minigioco del giorno, selezionato in modo deterministico dal giorno del campionato.
- Una prova non classificata; due partite classificate al giorno. Per la classifica conta il miglior punteggio valido.
- Terzo tentativo consentito solo se il giocatore risulta ultimo nella classifica giornaliera **oppure** in quella generale, verificato dal server al momento della richiesta.
- Per evitare pareggi casuali: punteggio, poi tempo di completamento, poi timestamp server.
- Classifica generale: somma dei punti giornalieri; spareggio sul numero di primi posti, poi punteggio dell'ultimo giorno.
- Campionato attivo solo con almeno 2 membri. Alla fine del giorno 21 i risultati vengono congelati.

Queste regole devono essere implementate lato server prima di poter garantire che nessuno possa manipolare punteggi o tentativi.
