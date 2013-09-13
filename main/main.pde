import java.util.*;

import javax.swing.JOptionPane;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.Socket;

/*
* Pegando imagens a serem usadas no jogo
*/
String curDir = System.getProperty("user.dir");
PImage imgX = loadImage(curDir+"/tic-tac-toe/assets/button_cancel.png");
PImage imgB = loadImage(curDir+"/tic-tac-toe/assets/bola.png");

/*
* Variaveis de controle do jogo
*/
public static int selecionado = 0; //qtd. dos quadrinhos já selecionados. Max. 9
//int vez = (int)random(0,2); //Sorteando que vai começar
//ver = 1 Jogador 1, vez = 0 Jogador Contra
/*
int [] [] tabuleiro = new int[3][3]; 
String [] [] tabEscolhido = new String[3][3];
*/

/*
* Var. das dimensões usadas
*/
int alturaCab = 60; //altura do cabeçalho
int larguraMax = 600, alturaMax = 600;

int w = larguraMax;
int h = alturaMax;
int coluna = w/3, linha = h/3;
int colunaUm = coluna, colunaDois = 2*coluna, colunaTres = w;
int linhaUm = linha, linhaDois = 2*linha, linhaTres = h;

// Conexão ao servidor
boolean conectado = conecta();

PrintStream saida;
Cliente jogador;

public void setup() {
  textFont(createFont("Arial",25));
  //size(displayWidth,displayHeight);
  size(larguraMax,alturaMax+alturaCab);
  background(0xff9900);
  //preencheTab();
}

/*
* @return TRUE se conectou ao servidor FALSE cc.
*/
public boolean conecta(){
  try {
      
      String nome = JOptionPane.showInputDialog(null,"Digite seu nome: ");
      
      if(nome == null || nome.isEmpty())
        return false;
      
      Socket socket = new Socket("127.0.0.1", 5555);// conectando ao IP do Servidor e Porta

      saida = new PrintStream(socket.getOutputStream());// controle do fluxo de comunicação com o servidor
        
      saida.println(nome);//envia o nome digitado para o servidor
      
      this.jogador = new Cliente(socket,nome);
      Thread thread = jogador;
      thread.start();

      return true;
   } catch (IOException e) {
      System.out.println("Falha na Conexao... .. ." + " IOException: " + e);
   }
   return false;
}

public void draw(){
  if(conectado){
    desenhaCabecalho();
    desenhaTabuleiro(larguraMax,alturaMax);
    desenhaSelecionados();
    boolean vencedor = haVencedor();
    
    if(vencedor)
    {
      noLoop();
      String winner;
      if(this.jogador.vez == 1)
      {
        winner = this.jogador.getNome();
      }
      else
      {
        winner = this.jogador.getContra().getNome();
      }
      
      int conf = JOptionPane.showConfirmDialog(null,winner+" é o vencedor!\nDeseja jogar novamente?","Mensagem",JOptionPane.OK_OPTION,JOptionPane.INFORMATION_MESSAGE);
      if(conf == 0){
        this.jogador.preencheTab();//Reinicia tabuleiro.
        try{
           this.jogador.send("new"+winner);
        }catch(IOException e){
           System.out.println("Erro VENCEDOR "+e);
        }
           
      }
    }
    else
    {
      if(jogador.selecionado == 9){
        noLoop();
        JOptionPane.showMessageDialog(null,"Jogo empatado!");
      }
    }
  }
  else{
    noLoop();
    JOptionPane.showMessageDialog(null,"Não foi possivel conectar-se ao servidor.");
    System.exit(0);
  }
}

public void mouseClicked() {
  selecao();
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
  
  jogador.setSelecionado(escLin,escCol);

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

  showIn(posIX, posIY, posFX, posFY, this.jogador.tabEscolhido[escLin][escCol], dimensaoImg);
  
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
  for(int i = 0; i < this.jogador.tabuleiro.length; i++){
    for(int j = 0; j < this.jogador.tabuleiro.length; j++){
      if(this.jogador.tabuleiro[i][j] == 1){
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

/*
*  Se Vez = 0 vez é do adversário
*/
public void desenhaCabecalho(){
  redraw();
  background(0xff9900);
  textAlign(CENTER);
  if(this.jogador.vez == 1){
    fill(0, 100, 0);
  }
  else
  {
    fill(255, 0, 0);
  }
  text(this.jogador.getNome(), 100, alturaCab/2+10);
  noFill();
  noStroke();
  
  if(this.jogador.vez == 0){
    fill(0, 100, 0);
  }
  else
  {
    fill(255, 0, 0);
  }
  text(this.jogador.getContra().getNome(), larguraMax-100, alturaCab/2+10);
  noFill();
  noStroke();
  rect(0,0, larguraMax, alturaCab);
}

public void printTab(){
  for(int i = 0; i < this.jogador.tabuleiro.length; i++){
    for(int j = 0; j < this.jogador.tabuleiro.length; j++){
      System.out.print(this.jogador.tabuleiro[i][j]);
    }
    System.out.println();
  }
}

public boolean haVencedor()
{
  try
  {
    for(int i = 0; i < this.jogador.tabEscolhido.length; i++)
    {
      if((!this.jogador.tabEscolhido[i][0].isEmpty() && this.jogador.tabEscolhido[i][0].equals(this.jogador.tabEscolhido[i][1]) && this.jogador.tabEscolhido[i][1].equals(this.jogador.tabEscolhido[i][2])) 
      ||(!this.jogador.tabEscolhido[0][i].isEmpty() && this.jogador.tabEscolhido[0][i].equals(this.jogador.tabEscolhido[1][i]) && this.jogador.tabEscolhido[1][i].equals(this.jogador.tabEscolhido[2][i])))
      {
        return true;
      }
    }
    
    //Diagonais
    if((!this.jogador.tabEscolhido[0][0].isEmpty() && this.jogador.tabEscolhido[0][0].equals(this.jogador.tabEscolhido[1][1]) && this.jogador.tabEscolhido[1][1].equals(this.jogador.tabEscolhido[2][2])) 
    ||(!this.jogador.tabEscolhido[0][2].isEmpty() && this.jogador.tabEscolhido[0][2].equals(this.jogador.tabEscolhido[1][1]) && this.jogador.tabEscolhido[1][1].equals(this.jogador.tabEscolhido[2][0])))
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

