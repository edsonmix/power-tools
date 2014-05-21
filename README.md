power-tools
===========

Command line tool for VTEX store development


## Instalação

Por enquanto a ferramenta ainda não está no NPM. Por isso são necessários alguns passos manuais para "instalá-la":

0. Você deve ter o pacote `coffee-script` instalado globalmente. Caso não tenha, use `npm i -g coffee-script`.
1. `git clone git@github.com:vtex/power-tools`
2. `git checkout rewrite`
3. `npm i`
4. Adicione `alias gvim='coffee "<caminho para o repo>/bin/vtex.coffee"'` ao seu `.bashrc`

## Uso básico

Para iniciar a sincronização, use o seguinte comando:

```bash
$ vtex sync <account> <session>
```

Caso você ainda não esteja autenticado, será pedido seu login e senha.
O diretório observado, relativo à pasta na qual o comando foi executado, será `/<account>`.
