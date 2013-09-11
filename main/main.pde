import java.util.*;

import javax.swing.JOptionPane;

import processing.core.PApplet;
import processing.core.PImage;

String curDir = System.getProperty("user.dir");
PImage imgX = loadImage(curDir+"/Hash-Game-Online/assets/button_cancel.png");
PImage imgB = loadImage(curDir+"/Hash-Game-Online/assets/bola.png");

public int selecionado = 0;
int vez = (int)random(0,2);
int [] [] tabuleiro = new int[3][3];
String [] [] tabEscolhido = new String[3][3];

int alturaCab = 60; //altura do cabeçalho
static final int larguraMax = 600, alturaMax = 600;

int w = larguraMax;
int h = alturaMax;
int coluna = w/3, linha = h/3;
int colunaUm = coluna, colunaDois = 2*coluna, colunaTres = w;
int linhaUm = linha, linhaDois = 2*linha, linhaTres = h;

PrintStream saida;

public void setup() {
  textFont(createFont("Arial",25));
  //size(displayWidth,displayHeight);
  size(larguraMax,alturaMax+alturaCab);
  background(0xff9900);
  preencheTab();
  conecta();
}

public void conecta(){
  try {
      //Instancia do atributo conexao do tipo Socket,
      // conecta a IP do Servidor, Porta
      Socket socket = new Socket("127.0.0.1", 5555);
      //Instancia do atributo saida, obtem os objetos que permitem
      // controlar o fluxo de comunicação
      saida = new PrintStream(socket.getOutputStream());
      String meuNome = JOptionPane.showInputDialog(null,"Digite seu nome: ");
      //envia o nome digitado para o servidor
      saida.println(meuNome.toUpperCase());
      //instancia a thread para ip e porta conectados e depois inicia ela
      Thread thread = new Cliente(socket);
      thread.start();
      //Cria a variavel msg responsavel por enviar a mensagem para o servidor
      String msg;
      //while (true)
      //{
        // cria linha para digitação da mensagem e a armazena na variavel msg
        //System.out.print("Mensagem > ");
        // envia a mensagem para o servidor
        saida.println(this.tabuleiro);
     //}
   } catch (IOException e) {
      System.out.println("Falha na Conexao... .. ." + " IOException: " + e);
   }
}

public void draw(){
  desenhaCabecalho();
  desenhaSelecionados();
  desenhaTabuleiro(larguraMax,alturaMax);
  boolean vencedor = haVencedor();
  
  if(vencedor)
  {
    noLoop();
    if(vez == 1)
    {
      JOptionPane.showMessageDialog(null,"Jogador 1 é o vencedor!");
    }
    else
    {
      JOptionPane.showMessageDialog(null,"Jogador 2 é o vencedor!");
    }
  }
  else
  {
    if(selecionado == 9){
      noLoop();
      JOptionPane.showMessageDialog(null,"Jogo empatado!");
    }
  }
}

public void mouseClicked() {
  selecao();
  //printTab();
}

public void selecao(){
  
  int escCol = 0; //1
  int escLin = 0; //1
  int w = 0;
  int h = 0;
  
  /** Primeira coluna clicada **/
  if(mouseX <= colunaUm){
    escCol = 0;
    if(mouseY < linhaUm){// primeira linha
      w = colunaUm;
      h = linhaUm;
      escLin = 0;//"linhaum";
    }
    else if(mouseY < linhaDois){ //segunda linha
      w = colunaUm;
      h = linhaDois;
      escLin = 1;//"linhadois";
    }
    else{ //terceira linha
      w = colunaUm;
      h = linhaTres;
      escLin = 2;//"linhatres";
    }
  }
  else if(mouseX <= colunaDois && mouseX > colunaUm){
    escCol =  1;//"colunadois";
    if(mouseY < linhaUm){// primeira linha
      w = colunaDois;
      h = linhaUm;
      escLin = 0;//"linhaum";
    }
    else if(mouseY < linhaDois){ //segunda linha
      w = colunaDois;
      h = linhaDois;
      escLin = 1;//"linhadois";
    }
    else{ //terceira linha
      w = colunaDois;
      h = linhaTres;
      escLin = 2;//"linhatres";
    }
  }
  else if(mouseX <= colunaTres && mouseX > colunaDois){
    escCol = 2;//"colunatres";
    if(mouseY < linhaUm){// primeira linha
      w = colunaTres;
      h = linhaUm;
      escLin = 0;//"linhaum";
    }
    else if(mouseY < linhaDois){ //segunda linha
      w = colunaTres;
      h = linhaDois;
      escLin = 1;//"linhadois";
    }
    else{ //terceira linha
      w = colunaTres;
      h = linhaTres;
      escLin = 2;//"linhatres";
    }
  }

  if(this.tabuleiro[escLin][escCol] != 1){
    this.tabuleiro[escLin][escCol] = 1;
    selecionado++;
    String escolha = "bola";
    if(this.vez == 1){
      escolha = "bola";
      this.vez = 0;
    }
    else if(this.vez == 0)
    {
      escolha = "x";
      this.vez = 1;
    }
    this.tabEscolhido[escLin][escCol] = escolha;
  }
  
}

public void selecionados(int line, int column){
  int escCol = 0, escLin = 0;
  int w = 0, h = 0;
  
  switch (column){
    case 0:
      w = colunaUm;
      escCol = 0;
      break;
      
    case 1:
      w = colunaDois;
      escCol = 1;
      break;
      
    default:
      w = colunaTres;
      escCol = 2;
      break;
  }
  
  switch (line){
    case 0:
      h = linhaUm;
      escLin = 0;
      break;
      
    case 1:
      h = linhaDois;
      escLin = 1;
      break;
      
    default:
      h = linhaTres;
      escLin = 2;
      break;
  }
  
  int clicadaX = w, clicadaY = h;
  int posIX = clicadaX - coluna, posIY = clicadaY - linha+alturaCab; //posição inicial do quadro clicado X e Y
  int posFX = w, posFY = h+alturaCab; //posicao final

   /** menor dimensao **/
  int dimensaoImg = posFX - posIX;

  showIn(posIX, posIY, posFX, posFY, this.tabEscolhido[escLin][escCol], dimensaoImg);
  
}

public void showIn(int posIX, int posIY, int posFX, int posFY,String escolha, int dimensao){

  int larg = posFX - posIX;  //calculando o largura do quatro da posição
  int alt = posFY - posIY; //calculando o altura do quatro da posição

  desenhaObjeto(larg, alt, posIX, posIY, dimensao,escolha);

}

/**
 * 
 * @param x largura
 * @param y altura
 * @param posIX posição vertical inicial 
 * @param posIY posição horizontal inicial
 * @param dimensao tamanho da imagem
 * @param tipo se o elemento selecionado é 'bola' ou 'x'
 */
public void desenhaObjeto(int x, int y, int posIX, int posIY, int dimensao,String tipo)
{
  PImage escolhida = imgB;
  
  imageMode(CENTER);
  if(tipo.toLowerCase().equals("bola")){
    // posX, posY, diamentroX, diamentroY;
    escolhida = imgB;
  }
  else if(tipo.toLowerCase().equals("x"))
  {
    // posX, posY, diamentroX, diamentroY;
    escolhida = imgX;
  }
  //JOptionPane.showMessageDialog(null," E "+escolhida.toString()+" IX "+(posIX+x/2)+" IY "+(posIY+y/2)+" D "+(dimensao/2)+" D "+(dimensao/2));
  image(escolhida,posIX+x/2,posIY+y/2,dimensao/2,dimensao/2);
}

public void desenhaSelecionados(){
  for(int i = 0; i < this.tabuleiro.length; i++){
    for(int j = 0; j < this.tabuleiro.length; j++){
      if(this.tabuleiro[i][j] == 1){
        selecionados(i, j);
      }
    }
  }
}

public void desenhaTabuleiro(int largura, int altura){
  
  /** linhas verticais **/
  int plnh = altura/3; //primeira linha horizontal
  int plnv = largura/3; //primeira linha vertical
  
  smooth();
  stroke(222);

  strokeWeight(10);
  // x, y, larg, alt
  rect(0,alturaCab, largura,altura);
  
  /** Linha verticais **/
    line(plnv,alturaCab,plnv,altura+alturaCab);
    line(2*plnv,alturaCab,2*plnv,altura+alturaCab);
    
    /** linhas horizontais **/
    line(0,plnh+alturaCab,largura,plnh+alturaCab);
    line(0,2*plnh+alturaCab,largura,2*plnh+alturaCab);
    
}

public void desenhaCabecalho(){
  redraw();
  textAlign(CENTER);
  if(vez == 0){
    fill(0, 100, 0);
  }
  else
  {
    fill(255, 0, 0);
  }
  text("Jogador 1", 100, alturaCab/2+10);
  noFill();
  noStroke();
  
  if(vez == 1){
    fill(0, 100, 0);
  }
  else
  {
    fill(255, 0, 0);
  }
  text("Jogador 2", larguraMax-100, alturaCab/2+10);
  noFill();
  noStroke();
  rect(0,0, larguraMax, alturaCab);
}

public void preencheTab(){
  for(int i = 0; i < tabuleiro.length; i++){
    for(int j = 0; j < tabuleiro.length; j++){
      this.tabuleiro[i][j] = 0;
      this.tabEscolhido[i][j] = "";
    }
  }
}

public void printTab(){
  for(int i = 0; i < tabuleiro.length; i++){
    for(int j = 0; j < tabuleiro.length; j++){
      System.out.print(this.tabuleiro[i][j]);
    }
    System.out.println();
  }
}

public boolean haVencedor()
{
  try
  {
    for(int i = 0; i < this.tabEscolhido.length; i++)
    {
      if((!this.tabEscolhido[i][0].isEmpty() && this.tabEscolhido[i][0].equals(this.tabEscolhido[i][1]) && this.tabEscolhido[i][1].equals(this.tabEscolhido[i][2])) 
      ||(!this.tabEscolhido[0][i].isEmpty() && this.tabEscolhido[0][i].equals(this.tabEscolhido[1][i]) && this.tabEscolhido[1][i].equals(this.tabEscolhido[2][i])))
      {
        return true;
      }
    }
    
    //Diagonais
    if((!this.tabEscolhido[0][0].isEmpty() && this.tabEscolhido[0][0].equals(this.tabEscolhido[1][1]) && this.tabEscolhido[1][1].equals(this.tabEscolhido[2][2])) 
    ||(!this.tabEscolhido[0][2].isEmpty() && this.tabEscolhido[0][2].equals(this.tabEscolhido[1][1]) && this.tabEscolhido[1][1].equals(this.tabEscolhido[2][0])))
    {
      return true;
    }
  }
  catch(Exception e)
  {
    JOptionPane.showMessageDialog(null," HA VENCEDOR "+e.getMessage());
  }
  
  return false;
}

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.Socket;

public class Cliente extends Thread {
  
    // parte que controla a recepção de mensagens do cliente
    private Socket conexao;
    // construtor que recebe o socket do cliente
    public Cliente(Socket socket) {
        this.conexao = socket;
    }
    
    // execução da thread
    public void run()
    {
        try {
            //recebe mensagens de outro cliente através do servidor
            BufferedReader entrada =
                new BufferedReader(new InputStreamReader(this.conexao.getInputStream()));
            //cria variavel de mensagem
            String msg;
            while (true)
            {
                // pega o que o servidor enviou
                msg = entrada.readLine();
                //se a mensagem contiver dados, passa pelo if,
                // caso contrario cai no break e encerra a conexao
                if (msg == null) {
                    System.out.println("Conexão encerrada!");
                    System.exit(0);
                }
                System.out.println();
                //imprime a mensagem recebida
                System.out.println(msg);
                //cria uma linha visual para resposta
                System.out.print("Responder > ");
            }
        } catch (IOException e) {
            // caso ocorra alguma exceção de E/S, mostra qual foi.
            System.out.println("Ocorreu uma Falha... .. ." +
                " IOException: " + e);
        }
    }
    
}
