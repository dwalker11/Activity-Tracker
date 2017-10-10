// JS
import 'bootstrap';

// Styles
import './styles.scss';

// Elm
import Elm from './Main.elm';

let node = document.getElementById('app');
Elm.Main.embed(node);
