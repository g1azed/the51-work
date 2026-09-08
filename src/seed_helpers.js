// ===== 업무일지 / 캘린더 시드 헬퍼 =====
SEED.options.calStatus = ['우선순위 1','우선순위 2','추후업무','분류대기','업무보류','제작완료','fixed','사업검수중','반영대기','반영완료'];
SEED.options.quad = ['작업중','디자인~ing','퍼블리싱 완료 후 검토 중','반영대기','대기','추후작업'];
SEED.cal = [];
const M = SEED.months;
function E(date, log, memo){ return { id:'j'+date.replace(/-/g,''), date, log:clean(log||''), memo:clean(memo||'') }; }
function T(nid, name, start, end, status, quad, done, time, who, notes){
  SEED.cal.push({ id:'c'+nid, nid, name:clean(name), start:start||'', end:end||'', status:status||'', quad:quad||'', done:!!done, time:time||'', who:who||[], notes:(notes||[]).map(clean) });
}
