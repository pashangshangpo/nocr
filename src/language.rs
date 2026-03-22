use serde::Serialize;
use std::fmt;

macro_rules! languages {
    ($( $name:ident => $iso:expr ),* $(,)?) => {
        #[derive(Clone, Debug, Serialize, Hash, Eq, PartialEq, Copy)]
        #[serde(rename_all = "kebab-case")]
        #[repr(usize)]
        pub enum Language {
            $($name),*
        }

        impl Language {
            pub fn as_lang_code(&self) -> &'static str {
                match self {
                    $(Language::$name => $iso),*
                }
            }

            pub fn from_code(code: &str) -> Option<Self> {
                match code {
                    $($iso => Some(Language::$name),)*
                    _ => None,
                }
            }
        }
    };
}

languages! {
    English => "en",
    Chinese => "zh",
    German => "de",
    Spanish => "es",
    Russian => "ru",
    Korean => "ko",
    French => "fr",
    Japanese => "ja",
    Portuguese => "pt",
    Turkish => "tr",
    Polish => "pl",
    Catalan => "ca",
    Dutch => "nl",
    Arabic => "ar",
    Swedish => "sv",
    Italian => "it",
    Indonesian => "id",
    Hindi => "hi",
    Finnish => "fi",
    Hebrew => "he",
    Ukrainian => "uk",
    Greek => "el",
    Malay => "ms",
    Czech => "cs",
    Romanian => "ro",
    Danish => "da",
    Hungarian => "hu",
    Norwegian => "no",
    Thai => "th",
    Urdu => "ur",
    Croatian => "hr",
    Bulgarian => "bg",
    Lithuanian => "lt",
    Latin => "la",
    Malayalam => "ml",
    Welsh => "cy",
    Slovak => "sk",
    Persian => "fa",
    Latvian => "lv",
    Bengali => "bn",
    Serbian => "sr",
    Azerbaijani => "az",
    Slovenian => "sl",
    Estonian => "et",
    Macedonian => "mk",
    Nepali => "ne",
    Mongolian => "mn",
    Bosnian => "bs",
    Kazakh => "kk",
    Albanian => "sq",
    Swahili => "sw",
    Galician => "gl",
    Marathi => "mr",
    Punjabi => "pa",
    Sinhala => "si",
    Khmer => "km",
    Afrikaans => "af",
    Belarusian => "be",
    Gujarati => "gu",
    Amharic => "am",
    Yiddish => "yi",
    Lao => "lo",
    Uzbek => "uz",
    Faroese => "fo",
    Pashto => "ps",
    Maltese => "mt",
    Sanskrit => "sa",
    Luxembourgish => "lb",
    Myanmar => "my",
    Tibetan => "bo",
    Tagalog => "tl",
    Assamese => "as",
    Tatar => "tt",
    Hausa => "ha",
    Javanese => "jw",
}

impl fmt::Display for Language {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_lang_code())
    }
}