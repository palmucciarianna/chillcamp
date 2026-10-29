package it.chillchamp.app

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import java.security.SecureRandom
import java.util.Locale
import java.util.concurrent.TimeUnit

private val Accent = Color(0xFF6876D8)
private val GameNames = listOf("Riflessi", "Memoria lampo", "Numero segreto", "Tap veloce", "Vero o falso", "Sequenza", "Calcolo sprint", "Parole al volo", "Occhio fino", "Scelta rapida")
private val GameDescriptions = listOf(
    "Tocca il pulsante appena compare. Il punteggio premia la rapidità.",
    "Memorizza la sequenza mostrata e ripetila nell'ordine corretto.",
    "Indovina il numero segreto scegliendo tra 1 e 20.",
    "Fai più tocchi possibile in 10 secondi.",
    "Rispondi correttamente a una serie di domande vero/falso.",
    "Ripeti una sequenza di colori senza sbagliare.",
    "Risolvi più operazioni possibile prima che scada il tempo.",
    "Trova la parola corretta tra le opzioni proposte.",
    "Individua il simbolo diverso in una griglia.",
    "Scegli la risposta giusta tra quattro opzioni."
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FirebaseApp.initializeApp(this)
        setContent { ChillChampApp(this) }
    }
}

@Composable
private fun ChillChampApp(activity: ComponentActivity) {
    val auth = remember { FirebaseAuth.getInstance() }
    val db = remember { FirebaseFirestore.getInstance() }
    var user by remember { mutableStateOf(auth.currentUser) }
    var nickname by remember { mutableStateOf(auth.currentUser?.displayName ?: "") }
    var page by remember { mutableStateOf("Gruppi") }
    var dark by remember { mutableStateOf(false) }
    var groups by remember { mutableStateOf(listOf<GroupItem>()) }
    var selectedGroup by remember { mutableStateOf<GroupItem?>(null) }
    var notice by remember { mutableStateOf("") }
    var showCreate by remember { mutableStateOf(false) }
    var showJoin by remember { mutableStateOf(false) }
    var createName by remember { mutableStateOf("") }
    var joinCode by remember { mutableStateOf("") }

    val signInLauncher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        try {
            val account = task.getResult(com.google.android.gms.common.api.ApiException::class.java)
            val credential = GoogleAuthProvider.getCredential(account.idToken, null)
            auth.signInWithCredential(credential).addOnSuccessListener {
                user = it.user
                nickname = it.user?.displayName ?: ""
                val u = it.user ?: return@addOnSuccessListener
                db.collection("users").document(u.uid).set(mapOf("email" to u.email, "nickname" to (u.displayName ?: ""), "updatedAt" to FieldValue.serverTimestamp()), com.google.firebase.firestore.SetOptions.merge())
            }.addOnFailureListener { notice = "Accesso non riuscito: ${it.localizedMessage}" }
        } catch (e: Exception) { notice = "Accesso annullato o non riuscito." }
    }
    fun startGoogleSignIn() {
        // Replace WEB_CLIENT_ID with the Web client ID from your Firebase project.
        val options = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail().requestIdToken("WEB_CLIENT_ID") .build()
        signInLauncher.launch(GoogleSignIn.getClient(activity, options).signInIntent)
    }
    fun refreshGroups(uid: String) {
        db.collection("users").document(uid).collection("groups").addSnapshotListener { snap, err ->
            if (err != null) { notice = err.localizedMessage ?: "Errore nel caricamento"; return@addSnapshotListener }
            groups = snap?.documents?.map { d -> GroupItem(d.id, d.getString("name") ?: "Gruppo", d.getString("role") ?: "member", d.getLong("day")?.toInt() ?: 1) } ?: emptyList()
        }
    }
    LaunchedEffect(user?.uid) { user?.uid?.let { refreshGroups(it) } }

    MaterialTheme(colorScheme = if (dark) darkColorScheme(primary = Accent) else lightColorScheme(primary = Accent)) {
        Surface(Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
            if (user == null) {
                Column(Modifier.fillMaxSize().padding(28.dp), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("ChillChamp", style = MaterialTheme.typography.headlineLarge, fontWeight = FontWeight.Bold)
                    Spacer(Modifier.height(8.dp)); Text("Piccole sfide, grandi rivalità.", color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(28.dp))
                    Button(onClick = { startGoogleSignIn() }, modifier = Modifier.fillMaxWidth()) { Icon(Icons.Default.Login, null); Spacer(Modifier.width(8.dp)); Text("Continua con Google") }
                    if (notice.isNotBlank()) Text(notice, color = MaterialTheme.colorScheme.error)
                    Text("Per attivare l'accesso serve collegare il progetto a Firebase (istruzioni nel README).", style = MaterialTheme.typography.bodySmall, modifier = Modifier.padding(top = 18.dp))
                }
            } else {
                Scaffold(bottomBar = {
                    NavigationBar {
                        NavigationBarItem(selected = page == "Gruppi", onClick = { page = "Gruppi" }, icon = { Icon(Icons.Default.Groups, null) }, label = { Text("Gruppi") })
                        NavigationBarItem(selected = page == "Settings", onClick = { page = "Settings" }, icon = { Icon(Icons.Default.Settings, null) }, label = { Text("Settings") })
                        NavigationBarItem(selected = page == "Statistiche", onClick = { page = "Statistiche" }, icon = { Icon(Icons.Default.EmojiEvents, null) }, label = { Text("Statistiche") })
                    }
                }) { padding ->
                    Column(Modifier.fillMaxSize().padding(padding).padding(horizontal = 18.dp)) {
                        Spacer(Modifier.height(18.dp))
                        if (selectedGroup != null) GroupDetail(selectedGroup!!, db, user!!.uid, onBack = { selectedGroup = null }, onNotice = { notice = it })
                        else when (page) {
                            "Gruppi" -> {
                                Row(verticalAlignment = Alignment.CenterVertically) { Column(Modifier.weight(1f)) { Text("I tuoi gruppi", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold); Text("21 giorni per scalare la classifica") }; IconButton(onClick = { showCreate = true }) { Icon(Icons.Default.AddCircle, "Crea gruppo") } }
                                Spacer(Modifier.height(12.dp))
                                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) { OutlinedButton(onClick = { showCreate = true }) { Icon(Icons.Default.Add, null); Text(" Crea") }; OutlinedButton(onClick = { showJoin = true }) { Icon(Icons.Default.Key, null); Text(" Entra con codice") } }
                                Spacer(Modifier.height(12.dp))
                                if (groups.isEmpty()) EmptyCard("Ancora nessun gruppo", "Crea un gruppo o inserisci il codice ricevuto da un amico.")
                                LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) { items(groups) { g -> GroupCard(g) { selectedGroup = g } } }
                            }
                            "Settings" -> {
                                Text("Settings", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold); Spacer(Modifier.height(18.dp))
                                Card { Column(Modifier.padding(16.dp)) { Text("Account", fontWeight = FontWeight.SemiBold); Spacer(Modifier.height(12.dp)); Text("Email"); Text(user!!.email ?: "—", color = MaterialTheme.colorScheme.onSurfaceVariant); Spacer(Modifier.height(12.dp)); Text("Nickname"); OutlinedTextField(value = nickname, onValueChange = { nickname = it }, singleLine = true, modifier = Modifier.fillMaxWidth()); Button(onClick = { db.collection("users").document(user!!.uid).set(mapOf("nickname" to nickname), com.google.firebase.firestore.SetOptions.merge()).addOnSuccessListener { notice = "Nickname salvato" }.addOnFailureListener { notice = "Errore nel salvataggio" } }) { Text("Salva nickname") } } }
                                Spacer(Modifier.height(12.dp)); Card { Row(Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) { Text("Tema scuro", Modifier.weight(1f)); Switch(checked = dark, onCheckedChange = { dark = it }) } }
                                Spacer(Modifier.height(12.dp)); OutlinedButton(onClick = { auth.signOut(); GoogleSignIn.getClient(activity, GoogleSignInOptions.DEFAULT_SIGN_IN).signOut(); user = null; groups = emptyList() }, modifier = Modifier.fillMaxWidth()) { Text("Esci dall'account") }
                            }
                            else -> {
                                Text("Le tue statistiche", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold); Spacer(Modifier.height(12.dp))
                                EmptyCard("Statistiche in arrivo", "Qui troverai i giochi giocati, i punteggi migliori, le partite vinte e i campionati vinti.")
                                GameNames.forEachIndexed { i, n -> ListItem(leadingContent = { Surface(color = Accent.copy(alpha = .12f), shape = RoundedCornerShape(12.dp)) { Box(Modifier.size(44.dp), contentAlignment = Alignment.Center) { Text("${i + 1}", color = Accent, fontWeight = FontWeight.Bold) } } }, headlineContent = { Text(n) }, supportingContent = { Text("Nessun punteggio registrato") }) }
                            }
                        }
                        if (notice.isNotBlank()) { Spacer(Modifier.height(8.dp)); Text(notice, color = MaterialTheme.colorScheme.primary); TextButton(onClick = { notice = "" }) { Text("Chiudi") } }
                    }
                }
            }
        }
    }
    if (showCreate && user != null) AlertDialog(onDismissRequest = { showCreate = false }, title = { Text("Crea un gruppo") }, text = { OutlinedTextField(value = createName, onValueChange = { createName = it }, label = { Text("Nome del gruppo") }, singleLine = true) }, confirmButton = { TextButton(onClick = {
        val name = createName.trim(); if (name.length < 2) { notice = "Inserisci un nome di almeno 2 caratteri"; return@TextButton }
        createGroup(db, user!!.uid, name) { ok, msg -> notice = msg; if (ok) { showCreate = false; createName = "" } }
    }) { Text("Crea") } }, dismissButton = { TextButton(onClick = { showCreate = false }) { Text("Annulla") } })
    if (showJoin && user != null) AlertDialog(onDismissRequest = { showJoin = false }, title = { Text("Entra in un gruppo") }, text = { OutlinedTextField(value = joinCode, onValueChange = { joinCode = it.uppercase(Locale.ROOT) }, label = { Text("Codice di invito") }, singleLine = true) }, confirmButton = { TextButton(onClick = { joinGroup(db, user!!.uid, joinCode.trim()) { ok, msg -> notice = msg; if (ok) { showJoin = false; joinCode = "" } } }) { Text("Entra") } }, dismissButton = { TextButton(onClick = { showJoin = false }) { Text("Annulla") } })
}

data class GroupItem(val id: String, val name: String, val role: String, val day: Int)

private fun newCode(): String {
    val chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; val r = SecureRandom()
    return (1..8).map { chars[r.nextInt(chars.length)] }.joinToString("")
}

private fun createGroup(db: FirebaseFirestore, uid: String, name: String, callback: (Boolean, String) -> Unit) {
    val groupRef = db.collection("groups").document()
    val code = newCode()
    val now = System.currentTimeMillis()
    val payload = hashMapOf<String, Any>("name" to name, "ownerId" to uid, "createdAtMs" to now, "startAtMs" to now, "endAtMs" to (now + TimeUnit.DAYS.toMillis(21)), "day" to 1, "memberCount" to 1, "inviteCode" to code, "inviteExpiresAtMs" to (now + TimeUnit.HOURS.toMillis(24)), "status" to "active")
    db.runBatch { batch ->
        batch.set(groupRef, payload)
        batch.set(groupRef.collection("members").document(uid), mapOf("uid" to uid, "role" to "owner", "joinedAtMs" to now))
        batch.set(db.collection("users").document(uid).collection("groups").document(groupRef.id), mapOf("name" to name, "role" to "owner", "day" to 1))
        batch.set(db.collection("inviteCodes").document(code), mapOf("groupId" to groupRef.id, "createdAtMs" to now, "expiresAtMs" to (now + TimeUnit.HOURS.toMillis(24)), "used" to false))
    }.addOnSuccessListener { callback(true, "Gruppo creato! Codice: $code (valido 24 ore). Condividilo con gli amici.") }.addOnFailureListener { callback(false, "Creazione non riuscita: ${it.localizedMessage}") }
}

private fun joinGroup(db: FirebaseFirestore, uid: String, code: String, callback: (Boolean, String) -> Unit) {
    if (code.length != 8) { callback(false, "Il codice deve contenere 8 caratteri."); return }
    val inviteRef = db.collection("inviteCodes").document(code)
    db.runTransaction { tx ->
        val invite = tx.get(inviteRef)
        val expires = invite.getLong("expiresAtMs") ?: 0L
        val groupId = invite.getString("groupId") ?: throw IllegalStateException("Codice non valido")
        if (System.currentTimeMillis() > expires) throw IllegalStateException("Codice scaduto: chiedi al creatore un nuovo invito")
        val groupRef = db.collection("groups").document(groupId)
        val group = tx.get(groupRef)
        val count = (group.getLong("memberCount") ?: 0L).toInt()
        if (count >= 30) throw IllegalStateException("Il gruppo ha raggiunto il limite di 30 giocatori")
        val name = group.getString("name") ?: "Gruppo"
        tx.set(groupRef.collection("members").document(uid), mapOf("uid" to uid, "role" to "member", "joinedAtMs" to System.currentTimeMillis()))
        tx.set(db.collection("users").document(uid).collection("groups").document(groupId), mapOf("name" to name, "role" to "member", "day" to (group.getLong("day") ?: 1L)))
        tx.update(groupRef, "memberCount", count + 1)
        name
    }.addOnSuccessListener { callback(true, "Sei entrato in $it!") }.addOnFailureListener { callback(false, it.message ?: "Impossibile entrare nel gruppo") }
}

@Composable private fun GroupCard(g: GroupItem, onClick: () -> Unit) {
    Card(Modifier.fillMaxWidth().clickable(onClick = onClick), border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant)) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Surface(color = Accent.copy(alpha = .12f), shape = RoundedCornerShape(14.dp)) { Box(Modifier.size(52.dp), contentAlignment = Alignment.Center) { Icon(Icons.Default.Groups, null, tint = Accent) } }
            Spacer(Modifier.width(12.dp)); Column(Modifier.weight(1f)) { Text(g.name, fontWeight = FontWeight.SemiBold); Text("Giorno ${g.day.coerceIn(1,21)} di 21", color = MaterialTheme.colorScheme.onSurfaceVariant, style = MaterialTheme.typography.bodySmall); LinearProgressIndicator(progress = { g.day.coerceIn(1,21) / 21f }, modifier = Modifier.fillMaxWidth().padding(top = 8.dp)) }
            Icon(Icons.Default.ChevronRight, null)
        }
    }
}

@Composable private fun EmptyCard(title: String, body: String) { Card(Modifier.fillMaxWidth()) { Column(Modifier.padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) { Icon(Icons.Default.SportsEsports, null, tint = Accent, modifier = Modifier.size(36.dp)); Spacer(Modifier.height(8.dp)); Text(title, fontWeight = FontWeight.SemiBold); Spacer(Modifier.height(4.dp)); Text(body, color = MaterialTheme.colorScheme.onSurfaceVariant) } } }

@Composable private fun GroupDetail(group: GroupItem, db: FirebaseFirestore, uid: String, onBack: () -> Unit, onNotice: (String) -> Unit) {
    var members by remember { mutableStateOf(0L) }; var owner by remember { mutableStateOf(false) }; var code by remember { mutableStateOf("") }; var day by remember { mutableIntStateOf(1) }; var gameIndex by remember { mutableIntStateOf(0) }; var showGame by remember { mutableStateOf(false) }
    LaunchedEffect(group.id) { db.collection("groups").document(group.id).addSnapshotListener { s, _ -> if (s != null) { members = s.getLong("memberCount") ?: 0; owner = s.getString("ownerId") == uid; day = s.getLong("day")?.toInt() ?: 1; code = s.getString("inviteCode") ?: "" } } }
    if (showGame) { MiniGameScreen(gameIndex, onBack = { showGame = false }, onScore = { score -> onNotice("Punteggio demo: $score. Per salvare i risultati online occorre completare le regole server.") }); return }
    Row(verticalAlignment = Alignment.CenterVertically) { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, null) }; Column { Text(group.name, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold); Text("${members} giocatori · giorno ${day.coerceIn(1,21)}/21", color = MaterialTheme.colorScheme.onSurfaceVariant) } }
    Spacer(Modifier.height(12.dp)); Card { Column(Modifier.padding(16.dp)) { Text("Campionato", fontWeight = FontWeight.SemiBold); Text("Il campionato dura 21 giorni. Ogni giorno ha un minigioco diverso."); LinearProgressIndicator(progress = { day.coerceIn(1,21) / 21f }, modifier = Modifier.fillMaxWidth().padding(vertical = 10.dp)); Text(if (members < 2) "Serve almeno un altro giocatore per iniziare la competizione." else "Gruppo pronto per giocare.", color = MaterialTheme.colorScheme.onSurfaceVariant) } }
    if (owner) { Spacer(Modifier.height(10.dp)); Card { Column(Modifier.padding(16.dp)) { Text("Invito (solo creatore)", fontWeight = FontWeight.SemiBold); Text("$code", style = MaterialTheme.typography.headlineMedium, color = Accent); Text("Il codice iniziale scade dopo 24 ore. La rigenerazione e la scadenza vanno rese atomiche lato server prima della pubblicazione.", style = MaterialTheme.typography.bodySmall); OutlinedButton(onClick = { onNotice("Codice invito: $code") }) { Text("Mostra codice") } } } }
    Spacer(Modifier.height(14.dp)); Text("Minigiochi", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.SemiBold); Spacer(Modifier.height(6.dp))
    LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) { items(GameNames.size) { i -> Card(Modifier.fillMaxWidth().clickable { gameIndex = i; showGame = true }) { ListItem(leadingContent = { Surface(color = Accent.copy(alpha = .12f), shape = RoundedCornerShape(10.dp)) { Box(Modifier.size(42.dp), contentAlignment = Alignment.Center) { Text("${i+1}", color = Accent, fontWeight = FontWeight.Bold) } } }, headlineContent = { Text(GameNames[i]) }, supportingContent = { Text("${if (i == ((day - 1) % 10)) "Gioco del giorno" else "Minigioco"} · prova disponibile") }, trailingContent = { Icon(Icons.Default.PlayArrow, null) }) } } }
}

@Composable private fun MiniGameScreen(index: Int, onBack: () -> Unit, onScore: (Int) -> Unit) {
    var started by remember { mutableStateOf(false) }; var score by remember { mutableIntStateOf(0) }; var answer by remember { mutableStateOf("") }; var target by remember { mutableIntStateOf((1..20).random()) }; var taps by remember { mutableIntStateOf(0) }; var finished by remember { mutableStateOf(false) }
    Column(Modifier.fillMaxSize().padding(18.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, null) }; Text(GameNames[index], style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold) }
        Spacer(Modifier.height(12.dp)); Text(GameDescriptions[index]); Spacer(Modifier.height(20.dp))
        if (!started) { EmptyCard("Prima di giocare", "Puoi fare una prova senza influenzare la classifica. Questa versione contiene meccaniche base per provare i minigiochi."); Spacer(Modifier.height(12.dp)); Button(onClick = { started = true }) { Text("Inizia prova") } }
        else when (index) {
            0 -> { Text("Premi il tasto il più velocemente possibile!"); Button(onClick = { taps++; score += 10; if (taps >= 10) finished = true }, modifier = Modifier.fillMaxWidth().height(100.dp)) { Text(if (finished) "Completato" else "TOCCA! (${taps}/10)") }; Text("Punti: $score") }
            1, 5 -> { Text("Memorizza: 2 · 4 · 1 · 3"); OutlinedTextField(answer, { answer = it }, label = { Text("Riscrivi la sequenza") }); Button(onClick = { score = if (answer.replace(" ", "") == "2413") 100 else 0; finished = true }) { Text("Verifica") } }
            2 -> { Text("Indovina il numero tra 1 e 20"); OutlinedTextField(answer, { answer = it.filter(Char::isDigit).take(2) }, label = { Text("Numero") }); Button(onClick = { val n = answer.toIntOrNull(); score = if (n == target) 100 else if (n != null) (100 - kotlin.math.abs(n-target)*5).coerceAtLeast(0) else 0; finished = true }) { Text("Conferma") } }
            3 -> { Text("Fai 20 tocchi per completare la sfida."); Button(onClick = { taps++; score += 5; if (taps >= 20) finished = true }, modifier = Modifier.fillMaxWidth().height(90.dp)) { Text("TAP! $taps/20") } }
            4 -> { Text("Il sole è una stella."); Row { Button(onClick = { score = 100; finished = true }) { Text("Vero") }; Spacer(Modifier.width(10.dp)); OutlinedButton(onClick = { score = 0; finished = true }) { Text("Falso") } } }
            6 -> { Text("Quanto fa 7 × 8?"); listOf("54", "56", "64", "48").forEach { opt -> OutlinedButton(onClick = { score = if (opt == "56") 100 else 0; finished = true }, modifier = Modifier.fillMaxWidth()) { Text(opt) } } }
            7 -> { Text("Quale parola è scritta correttamente?"); listOf("Aquilone", "Aquilonee", "Acquilone", "Aquiloni").forEach { opt -> OutlinedButton(onClick = { score = if (opt == "Aquilone") 100 else 0; finished = true }, modifier = Modifier.fillMaxWidth()) { Text(opt) } } }
            8 -> { Text("Trova il numero diverso: 8 · 8 · 8 · 3 · 8"); listOf("8", "3", "8", "8").forEach { opt -> OutlinedButton(onClick = { score = if (opt == "3") 100 else 0; finished = true }, modifier = Modifier.fillMaxWidth()) { Text(opt) } } }
            else -> { Text("Qual è il pianeta più vicino al Sole?"); listOf("Venere", "Marte", "Mercurio", "Terra").forEach { opt -> OutlinedButton(onClick = { score = if (opt == "Mercurio") 100 else 0; finished = true }, modifier = Modifier.fillMaxWidth()) { Text(opt) } } }
        }
        if (finished) { Spacer(Modifier.height(16.dp)); Text("Punteggio: $score", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold); Button(onClick = { onScore(score); onBack() }) { Text("Fine prova") } }
    }
}
