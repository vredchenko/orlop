/**
 * Every component will have a service class CLI
 * inheriting from this class
 */

abstract class LibItem {
    name: string;
    desc: string;
    version: string;
    refs: string[];

    constructor(dir: string) {}

    // public CLI commands
    install() {}
    checkLatestVersion() {}
    test() {}
    docs() {}

    private loadFromConf() {}
    private updateVersion(versionNu: string) {
        // update version in index.yml and VERSION
    }
}