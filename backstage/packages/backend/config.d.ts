export interface Config {
  goldenpath: {
    /** @visibility frontend */
    localMode: boolean;
    githubOwner: string;
    gitopsRepo: string;
    serviceImage: string;
    teams: {[team: string]: {namespace: string; costCenter: string; owner: string; members: string[]}};
  };
}
