import "../output/init.mjs";

const database = abap.context.defaultDB();
await database.execute("DELETE FROM zsalloc_stock; DELETE FROM mard;");
await database.execute(
  "INSERT INTO mard (mandt, matnr, werks, lgort, labst) " +
    "VALUES ('000', 'MAT-1', '1000', '0001', 5);",
);

const first = new abap.Classes.ZCL_SALLOC_STOCK_SAP();
const second = new abap.Classes.ZCL_SALLOC_STOCK_SAP();
const reserve = (stock) =>
  stock["zif_salloc_stock$reserve"]({
    iv_material: "MAT-1",
    iv_plant: "1000",
    iv_quantity: 4,
  });

const results = await Promise.allSettled([reserve(first), reserve(second)]);
const successes = results.filter((result) => result.status === "fulfilled");
const failures = results.filter((result) => result.status === "rejected");
const { rows } = await database.select({
  select: "SELECT reserved FROM zsalloc_stock WHERE matnr = 'MAT-1' AND werks = '1000'",
});

if (successes.length > 1 || failures.length < 1 || rows[0]?.reserved !== 4) {
  const reasons = failures.map((result) => {
    const reason = result.reason;
    return reason?.reason?.get?.() || reason?.message || String(reason);
  });
  throw new Error(
    `Concurrency invariant failed: successes=${successes.length}, failures=${failures.length}, reserved=${rows[0]?.reserved}, reasons=${reasons.join(" | ")}`,
  );
}

console.log(
  `Concurrent reservation safety passed: successes=${successes.length}, failures=${failures.length}, reserved=4`,
);
