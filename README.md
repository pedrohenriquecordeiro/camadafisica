# Camada Fisica 

>- **Camada Fisica:** https://github.com/pedrohenriquecordeiro/camadafisica
>- **Camada Rede:** https://github.com/thiagofigcosta/camadarede
>- **Camada Transporte:** https://github.com/Bernard2254/camadatransporte
>- **Camada Aplicação:** https://github.com/thiagofigcosta/camadaaplicacao

>- **Todas as camadas:** https://github.com/thiagofigcosta/tcpip_layers

Implementacao da Camada de Transporte  do Trabalho Prático de Redes 1 - CEFET-MG

  - Integrantes do grupo:
    + Bernard Menezes Moreira da Costa bernard.menezes98@gmail.com
    + Pedro Henrique Cordeiro de Jesus pedro.henrique.cefetmg@gmail.com
    + Thiago Figueiredo Costa thiagofigcosta@hotmail.com
    + Marcos Tiago Ferreira Henriques marcostiagofh@gmail.com

O Enunciado está neste __[link.](https://docs.google.com/document/d/1O3cNM0T6gFNz9PeMYcnzbmBzEe8J7k34DaefJDSsv4A/edit)__

___

---

***

## Relação de Linguagens Escolhidas 

| Camada        | Linguagem   |
| ------------- | ----------- |
| aplicação     | python      |
| transporte    | javascript  |
| rede          | swift       |
| fisica        | perl        |
___


## Uso do Código

### Camada Física
Instale a linguagem `perl`

Instale os pacotes necessários, através dos comandos:

    cpan
    install IO::Socket::INET
    install Time::HiRes
    install Net::Address::IP::Local
    install Try::Tiny


Para executar basta rodar os comandos:
```
    sudo perl physical.pl   # executar como servidor
	perl physical.pl        # executar como cliente
```
