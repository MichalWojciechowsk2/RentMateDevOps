using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace ApplicationCore.Enums.DistrictByCity
{
    public enum KrakowDistricts
    {
        [Display(Name ="Stare Miasto")]
        StareMiasto,
        [Display(Name = "Grzegórzki")]
        Grzegorzki,
        [Display(Name = "Prądnik Czerwony")]
        PradnikCzerwony,
        [Display(Name = "Prądnik Biały")]
        PradnikBialy,
        [Display(Name = "Krowodrza")]
        Krowodrza,
        [Display(Name = "Bronowice")]
        Bronowice,
        [Display(Name = "Zwierzyniec")]
        Zwierzyniec,
        [Display(Name = "Dębniki")]
        Debniki,
        [Display(Name = "Łagiewniki-Borek Fałęcki")]
        LagiewnikiBorekFalecki,
        [Display(Name = "Swoszowice")]
        Swoszowice,
        [Display(Name = "Podgórze Duchackie")]
        PodgorzeDuchackie,
        [Display(Name = "Bieżanów-Prokocim")]
        BiezanowProkocim,
        [Display(Name = "Podgórze")]
        Podgorze,
        [Display(Name = "Czyżyny")]
        Czyzyny,
        [Display(Name = "Mistrzejowice")]
        Mistrzejowice,
        [Display(Name = "Bieńczyce")]
        Bienczyce,
        [Display(Name = "Wzgórza Krzesławickie")]
        WzgorzaKrzeslawickie,
        [Display(Name = "Nowa Huta")]
        NowaHuta
    }
}
