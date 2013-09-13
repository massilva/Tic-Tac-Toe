import javax.swing.JOptionPane;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.Socket;

public class Cliente extends Thread{
  
    // parte que controla a recepção de mensagens do cliente
    private Socket conexao;
    private String msg;
    private String nome;
    private Cliente jogador2;//jogador contra
    private String nJ2 = "Jogador 2";
    private PrintStream saida;
    public int [] [] tabuleiro = new int[3][3]; 
    public String [] [] tabEscolhido = new String[3][3];
    public int vez, selecionado;
    private String escolha;
    
    public Cliente(String nome){
        this.nome = nome;
        this.vez = 0;
        this.selecionado = 0;
        this.escolha = "bola";
    }
    
    public Cliente(String nome, int vez){
        this.nome = nome;
        this.vez = vez;
        this.selecionado = 0;
        this.escolha = "bola";
    }
    
    //usando quando conecta-se ao servidor
    public Cliente(Socket socket,String nome) {
        this.conexao = socket;
        this.escolha = "x";
        preencheTab();
        
        try{
          this.selecionado = 0;
          this.vez = 1;
          this.saida = new PrintStream(this.conexao.getOutputStream());
        } catch (IOException e) {
          System.out.println("Falha na Conexao... .. ."+" IOException: " + e);
        }
                
        this.nome = nome;
        this.jogador2 = new Cliente(nJ2);
    }
    
    public void run()
    {
        try {

            //recebe mensagens de outro cliente através do servidor
            BufferedReader entrada = 
                new BufferedReader(new InputStreamReader(this.conexao.getInputStream()));
            
            while (true)
            {
               this.msg = entrada.readLine(); //msg vinda do servidor

               //se a mensagem não contiver dados, cai no break e encerra a conexao
               if (msg == null){
                    System.out.println("Conexão encerrada!");
                    System.exit(0);
               }

               System.out.println();
               
               /** Simbolos
               *  Iniciar com '#' novo usuário criado
               *  Iniciar com '@' usuário saiu
               *  Iniciar com '!' erro
               *  Iniciar com '&' diz quem está online
               *  Iniciar com '*' passando posição clicada tabuleiro
               *  Iniciar com 'new' jogar novamente
               *  Iniciar com 'nnew' não aceitar pedido de jogar novamente
               *  Iniciar com 'onew' aceita pedido de jogar novamente
               *  Igual ACP aceito pedido de iniciar partida
               *  Igual NACP pedido de iniciar partida não aceito.
               */
               if(msg.startsWith("new")){
                 String nome = msg.substring(4,msg.length());
                 int conf = JOptionPane.showConfirmDialog(null,":'( "+nome+" lhe venceu e está lhe oferecendo uma revanche. Aceita?","Mensagem",JOptionPane.OK_OPTION,JOptionPane.QUESTION_MESSAGE);
                 if(conf == 0){
                   preencheTab();//Reinicia tabuleiro.
                   send("onew");
                 }
                 else{
                   send("nnew");
                   System.exit(0);
                 }
               }
               
               if(msg.startsWith("*")){
                  JOptionPane.showMessageDialog(null,"msg "+msg);
                  String [] m = msg.substring(1,msg.length()).split("#");
                  String escolhido = m[1];//Passando se é bola ou x
                  String [] pos = m[0].split(",");//posição clicada
                  int i = Integer.parseInt(pos[0]);
                  int j = Integer.parseInt(pos[1]);
                  this.tabuleiro[i][j] = 1;
                  this.tabEscolhido[i][j] = escolhido;
                  this.vez = 1; 
                  this.jogador2.vez = 0;
                  if(escolhido.equals("x"))
                  {
                    this.escolha = "bola";
                  }
                  else{
                    this.escolha = "x";
                  }  
                  //JOptionPane.showMessageDialog(null,"POS: "+i+","+j+"\n"+escolhido);
               }
               
               if(msg.startsWith("#")){
                 String nm = msg.substring(1,msg.length());
                 int a = JOptionPane.showConfirmDialog(null,"Olá "+nome+", você deseja iniciar uma partida com "+nm+"?","Solicitação de Partida",JOptionPane.OK_OPTION,JOptionPane.QUESTION_MESSAGE);
                 if(a==0){
                    this.vez = 1;
                    this.jogador2 = new Cliente(nm,0);
                    preencheTab();
                    send("ACP");
                 }
                 else{
                    send("NACP");
                 }
               }
               
               if(msg.equals("ACP"))
               {
                 preencheTab();
               }
                              
               /*
               *  Usuário que está entrando recebe a informação de quem está online
               */
               if(msg.startsWith("&")){
                  String nm = msg.substring(1,msg.length());
                  this.vez = 0;
                  //int a = JOptionPane.showConfirmDialog(null,nome+", "+nm+" lhe convidou para iniciar uma nova partida. Aceita?","Solicitação de Partida",JOptionPane.OK_OPTION,JOptionPane.QUESTION_MESSAGE);
                  this.jogador2 = new Cliente(nm,1);
               }
               
               if(msg.equals("@")){
                 JOptionPane.showMessageDialog(null,this.jogador2.getNome()+" saiu do jogo!");
                 preencheTab();
                 this.jogador2 = new Cliente(nJ2);  
               }
               
               System.out.println("S: "+msg);
            }
        } catch (IOException e) {
            System.out.println("Ocorreu uma Falha... .. ." +
                " IOException: " + e);
        }
    }
    
    public String getMsg(){
      return this.msg;
    }

    public String getNome(){
      return this.nome;
    }
    
    public Cliente getContra(){
      return jogador2; 
    }
    
    public void send(String msg) throws IOException{
      this.saida.println(msg);
    }
    
    public void preencheTab(){
      for(int i = 0; i < tabuleiro.length; i++){
        for(int j = 0; j < tabuleiro.length; j++){
          this.tabuleiro[i][j] = 0;
          this.tabEscolhido[i][j] = "";
        }
      }
    }
  
    public void setSelecionado(int escLin, int escCol){
      if(this.tabuleiro[escLin][escCol] != 1){
        this.tabuleiro[escLin][escCol] = 1;
        selecionado++;
        //String escolha = "bola";
        //JOptionPane.showMessageDialog(null,"VEZ: "+vez);
        if(this.vez == 1){
          //escolha = "bola";
          this.vez = 0;
          this.jogador2.vez = 1;
        }
        else if(this.vez == 0)
        {
          //escolha = "x";
          this.vez = 1;
          this.jogador2.vez = 0;
        }
        //enviando a posição selecionada para o outro jogador
        String m = "*"+escLin+","+escCol+"#"+this.escolha;
        //System.out.println(m);
        try{
          send(m);
        }catch(IOException e){
          System.out.println(e);
        }
        this.tabEscolhido[escLin][escCol] = this.escolha;
      }
  
   }  
 
}
