// Bespoke WDB settings for AWS finspace Starter Pack
\d .wdb
reload:0b //set reload to false so that replay isnt carried out during intial subscribe process
upd:(::)  //set upd to discard data until the end of period signals the start of new period

