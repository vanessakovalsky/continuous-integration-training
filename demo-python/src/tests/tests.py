from .. import main

def test_replaceComByFr():
    assert main.replaceComByFr('toto@gmail.com') == 'toto@gmail.fr'
