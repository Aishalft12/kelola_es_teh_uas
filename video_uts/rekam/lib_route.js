const fs=require('fs');
module.exports=async function setup(ctx){
  await ctx.route(/gstatic\.com\/flutter-canvaskit\/[^/]+\/(.*)$/, r=>{
    const rel=r.request().url().match(/flutter-canvaskit\/[^/]+\/(.*)$/)[1];
    const f='/home/claude/video/app/canvaskit/'+rel;
    if(!fs.existsSync(f)){console.log('MISSING',rel);return r.abort();}
    r.fulfill({body:fs.readFileSync(f),contentType:rel.endsWith('.wasm')?'application/wasm':'text/javascript'});
  });
  await ctx.route(/fonts\.gstatic\.com/, r=>{
    const u=r.request().url();
    if(u.includes('roboto')) return r.fulfill({body:fs.readFileSync('/home/claude/video/Roboto.ttf'),contentType:'font/ttf'});
    console.log('FONT?',u); r.abort();
  });
};
