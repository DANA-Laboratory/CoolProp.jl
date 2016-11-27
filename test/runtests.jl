using CoolProp
using Base.Test
#low
info("lowlevel Api test")
const HEOS_BACKEND_FAMILY = "HEOS";
const REFPROP_BACKEND_FAMILY = "REFPROP";#Need Install
const INCOMP_BACKEND_FAMILY = "INCOMP";
const IF97_BACKEND_FAMILY = "IF97";
const TREND_BACKEND_FAMILY = "TREND";#Not Imple
const TTSE_BACKEND_FAMILY = "TTSE";
const BICUBIC_BACKEND_FAMILY = "BICUBIC";
const SRK_BACKEND_FAMILY = "SRK";
const PR_BACKEND_FAMILY = "PR";
const VTPR_BACKEND_FAMILY = "VTPR";#Need Install
HEOS = AbstractState_factory(HEOS_BACKEND_FAMILY, "R245fa");
TTSE = AbstractState_factory(HEOS_BACKEND_FAMILY * "&" * TTSE_BACKEND_FAMILY, "R245fa");
BICU = AbstractState_factory(HEOS_BACKEND_FAMILY * "&" * BICUBIC_BACKEND_FAMILY, "R245fa");
SRK = AbstractState_factory(SRK_BACKEND_FAMILY, "R245fa");
PR = AbstractState_factory(PR_BACKEND_FAMILY, "R245fa");
PT_INPUTS = get_input_pair_index("PT_INPUTS");
AbstractState_update(HEOS, PT_INPUTS, 101325, 300);
AbstractState_update(TTSE, PT_INPUTS, 101325, 300);
AbstractState_update(BICU, PT_INPUTS, 101325, 300);
AbstractState_update(SRK, PT_INPUTS, 101325, 300);
AbstractState_update(PR, PT_INPUTS, 101325, 300);
rhmolar = get_param_index("DMOLAR");
println("HEOS:", AbstractState_keyed_output(HEOS, rhmolar));
@time AbstractState_keyed_output(HEOS, rhmolar);
println("TTSE:", AbstractState_keyed_output(TTSE, rhmolar));
@time AbstractState_keyed_output(TTSE, rhmolar);
println("BICU:", AbstractState_keyed_output(BICU, rhmolar));
@time AbstractState_keyed_output(BICU, rhmolar);
println("SRK:", AbstractState_keyed_output(SRK, rhmolar));
@time AbstractState_keyed_output(SRK, rhmolar);
println("PR:", AbstractState_keyed_output(PR, rhmolar));
@time AbstractState_keyed_output(PR, rhmolar);
AbstractState_free(HEOS);
AbstractState_free(TTSE);
AbstractState_free(BICU);
AbstractState_free(SRK);
AbstractState_free(PR);
IF97 = AbstractState_factory(IF97_BACKEND_FAMILY, "");
println("IF97::Water property for PT_INPUTS @pin @tin")
pin = 101325;
tin = 308.15;
AbstractState_update(IF97, PT_INPUTS, pin, tin);
for p in "PTHDSAUCO"
  pi = get_param_index("$p");
  println("IF97 $p = ", AbstractState_keyed_output(IF97, pi));
end
try
  println("IF97::Water property for QT_INPUTS @qin @tin")
  QT_INPUTS = get_input_pair_index("QT_INPUTS");
  qin = 0.5;
  AbstractState_update(IF97, QT_INPUTS, qin, tin);
  for p in "PTHDSAUQ"
    pi = get_param_index("$p");
    println("IF97 $p = ", AbstractState_keyed_output(IF97, pi));
  end
catch
  println("QT_INPUTS not ready");
end
AbstractState_free(IF97);
#origin
info("origin test")
@test (CoolProp.PropsSI("T","P",101325.0,"Q",0.0,"Water")-373.1242958476879)<1e-5
# See https://github.com/CoolProp/CoolProp/issues/1293
for param in ["version", "gitrevision", "errstring", "warnstring", "FluidsList", "incompressible_list_pure", "incompressible_list_solution", "mixture_binary_pairs_list", "parameter_list", "predefined_mixtures", "HOME", "cubic_fluids_schema"]
  println(param * " = " * get_global_param_string(param))
end
#high
info("highleval Api test");
const coolproptrivialparameters = ["ACENTRIC", "DIPOLE_MOMENT", "FH", "FRACTION_MAX", "FRACTION_MIN",
  "GAS_CONSTANT", "GWP100", "GWP20", "GWP500", "HH", "M", "ODP", "PCRIT", "PH", "PMAX", "PMIN", "PTRIPLE",
  "P_REDUCING", "RHOCRIT", "RHOMASS_REDUCING", "RHOMOLAR_CRITICAL", "RHOMOLAR_REDUCING", "TCRIT", "TMAX",
  "TMIN", "TTRIPLE", "T_FREEZE", "T_REDUCING"];
const coolpropmapping = Dict("molarGasConstant"=>"gas_constant", "acentricFactor"=>"ACENTRIC", "criticalDensity"=>"RHOMOLAR_CRITICAL", "criticalPressure"=>"PCRIT", "criticalTemperature"=>"TCRIT", "triplePointPressure"=>"PTRIPLE", "triplePointTemperature"=>"TTRIPLE");
const trivalwithnumval = ["FH","GWP100","PMIN","TMIN","P_REDUCING","PCRIT","GWP20","GAS_CONSTANT","PMAX","RHOCRIT","TCRIT","T_REDUCING","ACENTRIC","GWP500","RHOMOLAR_REDUCING","TMAX","TTRIPLE","PH","M","PTRIPLE","RHOMOLAR_CRITICAL","ODP","HH"];
const trivalwithoutnumval = ["DIPOLE_MOMENT","FRACTION_MAX","FRACTION_MIN","RHOMASS_REDUCING","T_FREEZE"];
const pseudopuremixtures = ["R134a","R116","n-Pentane","R11","n-Nonane","MDM","Oxygen","R41","MM","Neon","Fluorine","n-Undecane","Isohexane","Helium","IsoButane","D5"];
println("testing CoolProp....")
#get_global_param_string
coolpropmix = split(get_global_param_string("predefined_mixtures"), ',');
coolpropfluids = split(get_global_param_string("FluidsList"),',');
coolpropparameters = split(get_global_param_string("parameter_list"),',');
#finding PROPERTIES WITH NUMERICAL VALUES in Trivial inputs
tpropwithnumval = Set();
for p in coolproptrivialparameters
  #get_parameter_information_string
  println(get_parameter_information_string(p, "long") * " in (" * get_parameter_information_string(p, "units") * ")");
  missed = Set();
  for fluid in coolpropfluids
    try
      res = ("$(PropsSI(String(p), String(fluid)))");
      push!(tpropwithnumval, p);
    catch err
      push!(missed, fluid);
    end
  end
  findfirst(trivalwithnumval, p) != 0 && length(missed) > 0 && println("can't get $p for $(collect(missed))");
  findfirst(trivalwithnumval, p) == 0 && println("$p in trival without numericalvalue")
end
@test tpropwithnumval == Set(trivalwithnumval);
@test Set(setdiff(coolproptrivialparameters, tpropwithnumval)) == Set(trivalwithoutnumval);
#get_fluid_param_string
id = 0;
counter = 0;
maxdiffreduvscriti = 0.0;
maxfluid = "";
ppm = Set();
for fluid in  coolpropfluids
  id+=1;
  print("\n$id-$fluid aliases:$(get_fluid_param_string(String(fluid), String("aliases")))");
  print(" cas:$(get_fluid_param_string(String(fluid), String("CAS")))");
  pure=get_fluid_param_string(String(fluid), String("pure"));
  print(" pure:$pure");
  print(" formula:$(get_fluid_param_string(String(fluid), String("formula")))");
  for bi in ["BibTeX-CONDUCTIVITY", "BibTeX-EOS", "BibTeX-CP0", "BibTeX-SURFACE_TENSION","BibTeX-MELTING_LINE","BibTeX-VISCOSITY"]
    print(" $bi:$(get_fluid_param_string(String(fluid), String(bi)))");
  end
  (pure == "true") && PropsSI("TCRIT", String(fluid))!=PropsSI("T_REDUCING", String(fluid)) && push!(ppm, fluid);
  diffreduvscriti = abs(PropsSI("TCRIT", String(fluid)) - PropsSI("T_REDUCING", String(fluid)));
  if (diffreduvscriti > maxdiffreduvscriti)
    maxfluid = fluid;
    maxdiffreduvscriti = diffreduvscriti;
  end
end
println("\nmax diff between reducing vs critical point temp: $maxdiffreduvscriti for $maxfluid");
@test ppm == Set(pseudopuremixtures);
println("pseudopuremixtures $ppm");
#PhaseSI
#set_reference_stateS
#get_param_index
#get_input_pair_index
#F2K
#K2F
#HAPropsSI
#AbstractState_factory
#AbstractState_free
#AbstractState_set_fractions
#AbstractState_update
#AbstractState_keyed_output
