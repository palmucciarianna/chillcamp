# ChillChamp — Flutter cross-platform starter

**Un solo progetto per Android e iOS.** Questo è il nuovo prototipo Flutter che prende spunto dalle schermate e dalle funzionalità del vecchio starter Kotlin, senza riutilizzarne il codice nativo.

## Stato di questa versione

Funziona in locale:
- schermata iniziale demo;
- elenco e creazione di gruppi locali;
- codice invito dimostrativo;
- campionato rappresentato su 21 giorni;
- 10 minigiochi dimostrativi;
- schermate statistiche;
- tema chiaro/scuro e stile Basic/Chill;
- niente audio o vibrazioni.

Non è ancora una versione online:
- Google Sign-In non è collegato;
- Firebase/Firestore non sono configurati;
- gruppi e risultati non si sincronizzano tra telefoni;
- inviti e scadenze non sono convalidati da un server;
- tentativi competitivi, classifica e campionato non sono ancora sicuri né completi.

**Non usare questa demo per una competizione reale.** I punteggi sono dimostrativi.

## Prima di tutto: conserva il vecchio ZIP

Tieni `ChillChamp-android.zip` e lo ZIP Kotlin interno come prototipi originali. Non sovrascriverli con questo progetto.

## Avvio sul Mac M2

### 1. Installa gli strumenti

- Flutter SDK: https://docs.flutter.dev/get-started/install/macos
- Android Studio: https://developer.android.com/studio
- Per iOS, installa Xcode dal Mac App Store e aprilo almeno una volta.

Dopo aver installato Flutter, apri Terminale ed esegui:

```bash
flutter doctor
```

Risolvi eventuali problemi indicati per Android. Per iOS servirà anche la parte Xcode, ma puoi iniziare subito con Android.

### 2. Estrai e apri il progetto

1. Estrai `ChillChamp-Flutter.zip`.
2. Apri Android Studio.
3. Seleziona **Open** e scegli la cartella `ChillChamp-Flutter` (quella che contiene `pubspec.yaml`).

### 3. Genera i progetti nativi Android e iOS

Da Terminale, entra nella cartella del progetto e lancia:

```bash
flutter create . --platforms=android,ios
flutter pub get
```

Questo genera i file nativi necessari per entrambe le piattaforme, mantenendo il codice condiviso in `lib/`.

### 4. Avvia l'emulatore Pixel 9a già configurato

1. In Android Studio apri **Tools → Device Manager**.
2. Avvia l'emulatore Pixel 9a già creato (l'impostazione concordata era Android 17 / API 37, immagine ARM64 con Google Play).
3. Attendi che Android finisca l'avvio e che il dispositivo compaia in Android Studio.

Se il dispositivo non compare, da Terminale esegui:

```bash
flutter devices
```

Poi avvia l'app dalla cartella del progetto:

```bash
flutter run
```

Se vengono mostrati più dispositivi, scegli il Pixel 9a dall'elenco oppure usa l'ID indicato da `flutter devices`:

```bash
flutter run -d ID_DEL_DISPOSITIVO
```

### 5. Come provare la demo

- Tocca **Esplora la demo**.
- In **Gruppi**, crea un gruppo e annota il codice generato.
- Apri il gruppo per vedere il campionato e i 10 minigiochi.
- Gioca a un minigioco e salva il punteggio demo.
- In **Statistiche**, vedi i risultati fatti in questa sessione.
- In **Impostazioni**, prova tema scuro e stile Basic/Chill.

I dati sono in memoria: chiudendo l'app, gruppi e punteggi demo possono andare persi.

## Prossimi passi consigliati

1. Verificare la UI sul Pixel 9a.
2. Inizializzare Git e conservare una versione pulita del prototipo.
3. Configurare Firebase per Flutter, Authentication Google e Firestore.
4. Implementare inviti con scadenza lato server, membri e permessi.
5. Implementare i tentativi e le classifiche con Cloud Functions o backend equivalente.
6. Aprire lo stesso progetto con Xcode e testare la build iOS.

## Nota sulla configurazione Firebase

Non inserire segreti o chiavi private nel repository. Prima di distribuire l'app, configurare regole Firestore restrittive e testarle. I punteggi e il numero di tentativi devono essere verificati lato server, non fidandosi del client.
