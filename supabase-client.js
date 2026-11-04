/* Public browser configuration. Publishable keys are designed for client-side use; never place service_role/secret keys here. */
(function(){
 'use strict';
 const url='https://wbodoxqobkonkafjhfoh.supabase.co';
 const publishableKey='sb_publishable_prCS7C7XXLIqY3VRZuGYxg__XLoXtug';
 if(!window.supabase||typeof window.supabase.createClient!=='function'){
  console.error('Supabase JS failed to load.');
  window.studyloadSupabase=null;
  return;
 }
 window.studyloadSupabase=window.supabase.createClient(url,publishableKey,{
  auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}
 });
})();